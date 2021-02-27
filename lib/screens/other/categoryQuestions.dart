import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:zapytaj/config/app_config.dart';
import 'package:zapytaj/models/category.dart';
import 'package:zapytaj/models/question.dart';
import 'package:zapytaj/providers/auth_provider.dart';
import 'package:zapytaj/services/api_repository.dart';
import 'package:zapytaj/utils/utils.dart';
import 'package:zapytaj/widgets/appbar_leading_button.dart';
import 'package:zapytaj/widgets/post_list_item.dart';
import 'package:flutter/material.dart';

class CategoryQuestionsScreen extends StatefulWidget {
  final Category category;

  const CategoryQuestionsScreen({Key key, this.category}) : super(key: key);

  @override
  _CategoryQuestionsScreenState createState() =>
      _CategoryQuestionsScreenState();
}

class _CategoryQuestionsScreenState extends State<CategoryQuestionsScreen> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  AuthProvider _authProvider;
  List<Question> _questions = [];
  int _page;
  bool _shouldStopRequests;
  bool _waitForNextRequest;
  bool _isLoading;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);

    _isLoading = true;
    _page = 1;

    _fetchData();
  }

  _fetchData() async {
    _shouldStopRequests = false;
    _waitForNextRequest = false;
    await _getQuestions();
    setState(() {
      _isLoading = false;
    });
  }

  _getQuestions() async {
    if (_shouldStopRequests) return;
    if (_waitForNextRequest) return;
    _waitForNextRequest = true;

    await ApiRepository.getQuestionsByCategory(context, widget.category.id,
            offset: PER_PAGE,
            page: _page,
            userId: _authProvider.user != null ? _authProvider.user.id : 0)
        .then((questions) {
      setState(() {
        _page = _page + 1;
        _waitForNextRequest = false;
        _questions.addAll(questions.data.toList());
      });
    });

    setState(() {});
  }

  void _onRefresh() async {
    setState(() {
      _isLoading = true;
    });
    _questions = [];
    _page = 1;
    _shouldStopRequests = false;
    _waitForNextRequest = false;
    await _getQuestions();
    _refreshController.refreshCompleted();
    _isLoading = false;
  }

  void _onLoading() async {
    await _getQuestions();

    if (mounted) {
      setState(() {});
      if (_shouldStopRequests) {
        _refreshController.loadNoData();
      } else {
        _refreshController.loadComplete();
      }
    }
  }

  _addToFavorite(int id) {
    setState(() {
      _questions.singleWhere((question) => question.id == id).favorite = 1;
    });
  }

  _removeFromFavorite(int id) {
    setState(() {
      _questions.singleWhere((question) => question.id == id).favorite = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _favoriteQuestions(),
    );
  }

  _appBar() {
    return AppBar(
      leading: AppBarLeadingButton(),
      title: Text(widget.category.name, style: TextStyle(color: Colors.black)),
      centerTitle: false,
    );
  }

  _favoriteQuestions() {
    return !_isLoading
        ? swipeToRefresh(
            context,
            refreshController: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: ListView.builder(
              itemCount: _questions.length,
              itemBuilder: (ctx, i) => PostListItem(
                question: _questions[i],
                addToFav: _addToFavorite,
                removeFromFav: _removeFromFavorite,
              ),
            ),
          )
        : Center(child: CircularProgressIndicator());
  }
}
