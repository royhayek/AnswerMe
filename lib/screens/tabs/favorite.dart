import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:zapytaj/config/app_config.dart';
import 'package:zapytaj/config/size_config.dart';
import 'package:zapytaj/models/question.dart';
import 'package:zapytaj/providers/app_provider.dart';
import 'package:zapytaj/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:zapytaj/services/api_repository.dart';
import 'package:zapytaj/utils/utils.dart';
import 'package:zapytaj/widgets/post_list_item.dart';

class FavoriteScreen extends StatefulWidget {
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  AuthProvider authProvider;
  AppProvider _appProvider;
  List<Question> _questions = [];
  int _page;
  bool _shouldStopRequests;
  bool _waitForNextRequest;
  bool _isLoading;

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    _appProvider = Provider.of<AppProvider>(context, listen: false);

    _isLoading = true;
    _page = 1;

    _fetchData();
  }

  _fetchData() async {
    if (_appProvider.favoriteQuestions.isNotEmpty) {
      setState(() {
        _questions = _appProvider.favoriteQuestions;
      });
    } else {
      _shouldStopRequests = false;
      _waitForNextRequest = false;
      await _getQuestions();
    }
    setState(() {
      _isLoading = false;
    });
  }

  _getQuestions() async {
    if (_shouldStopRequests) return;
    if (_waitForNextRequest) return;
    _waitForNextRequest = true;

    await ApiRepository.getFavoriteQuestions(
      context,
      userId: authProvider.user != null ? authProvider.user.id : 0,
      offset: PER_PAGE,
      page: _page,
    ).then((questions) {
      setState(() {
        _page = _page + 1;
        _waitForNextRequest = false;
      });
      setState(() {
        _questions.addAll(questions.data.toList());
        _appProvider.setFavoriteQuestions(questions.data);
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

  _revomeFromFavorite(int id) {
    setState(() {
      _questions.removeWhere((question) => question.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _body(),
    );
  }

  _appBar() {
    return AppBar(
      title: Text('Favorite', style: TextStyle(color: Colors.black)),
    );
  }

  _body() {
    return authProvider.user == null
        ? _emptyFavoriteScreen(
            'Please login first, so you can use favorites.',
          )
        : !_isLoading
            ? _questions.isEmpty
                ? _emptyFavoriteScreen('No Favorites Yet')
                : _favoriteQuestions()
            : Center(child: CircularProgressIndicator());
  }

  Widget _favoriteQuestions() {
    return swipeToRefresh(
      context,
      refreshController: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: ListView.builder(
        itemCount: _questions.length,
        itemBuilder: (ctx, i) => PostListItem(
          question: _questions[i],
          removeFromFav: _revomeFromFavorite,
        ),
      ),
    );
  }

  _emptyFavoriteScreen(String text) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              color: Colors.grey.shade300,
              size: SizeConfig.blockSizeHorizontal * 11,
            ),
            Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: SizeConfig.safeBlockHorizontal * 3.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
