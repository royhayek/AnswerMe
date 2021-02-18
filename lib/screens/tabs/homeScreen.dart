import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:zapytaj/config/app_config.dart';
import 'package:zapytaj/models/question.dart';
import 'package:zapytaj/providers/app_provider.dart';
import 'package:zapytaj/providers/auth_provider.dart';
import 'package:zapytaj/screens/other/askQuestion.dart';
import 'package:zapytaj/screens/other/search.dart';
import 'package:zapytaj/services/api_repository.dart';
import 'package:zapytaj/utils/session_manager.dart';
import 'package:zapytaj/utils/utils.dart';
import 'package:zapytaj/widgets/post_list_item.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/size_config.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  TabController _tabController;
  AuthProvider authProvider;
  AppProvider appProvider;
  List<Question> _questions = [];
  int _page;
  bool _shouldStopRequests;
  bool _waitForNextRequest;
  bool _isLoading;

  final List<Tab> tabs = <Tab>[
    Tab(text: 'Recent Questions'),
    Tab(text: 'Most Answered'),
    Tab(text: 'Bump Question'),
    Tab(text: 'Most Visited'),
    Tab(text: 'Most Voted'),
    Tab(text: 'No Answers'),
  ];

  @override
  void initState() {
    super.initState();
    _getUserInfo();
    _fetchData('recentQuestions');

    _tabController = new TabController(vsync: this, length: tabs.length);

    _tabController.addListener(() {
      _fetchData(getEndpoint(_tabController.index));
      print("Selected Index: " + _tabController.index.toString());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _fetchData(String endpoint) async {
    setState(() {
      _questions = [];
      _page = 1;
      _isLoading = true;
    });
    _shouldStopRequests = false;
    _waitForNextRequest = false;

    await _getQuestions(endpoint);
    setState(() {
      _isLoading = false;
    });
  }

  _getQuestions(String endpoint) async {
    if (_shouldStopRequests) return;
    if (_waitForNextRequest) return;
    _waitForNextRequest = true;
    await ApiRepository.getRecentQuestions(context, endpoint,
            offset: PER_PAGE, page: _page)
        .then((questions) {
      setState(() {
        _page = _page + 1;
        _waitForNextRequest = false;
        print(questions.data);
        if (questions.data != null) _questions.addAll(questions.data.toList());
      });
    });

    setState(() {});
  }

  void _onRefresh(String tab) async {
    setState(() {
      _isLoading = true;
    });
    _questions = [];
    _page = 1;
    _shouldStopRequests = false;
    _waitForNextRequest = false;
    switch (tab) {
      case 'Recent Questions':
        await _getQuestions('recentQuestions');
        break;
      case 'Most Answered':
        await _getQuestions('mostAnsweredQuestions');
        break;
      case 'Bump Question':
        await _getQuestions('mostAnsweredQuestions');
        break;
      case 'Most Visited':
        await _getQuestions('mostVisitedQuestions');
        break;
      case 'Most Voted':
        await _getQuestions('mostVotedQuestions');
        break;
      case 'No Answers':
        await _getQuestions('noAnsweredQuestions');
        break;
      default:
    }
    _refreshController.refreshCompleted();
    _isLoading = false;
  }

  void _onLoading(String endpoint) async {
    await _getQuestions(endpoint);

    if (mounted) {
      setState(() {});
      if (_shouldStopRequests) {
        _refreshController.loadNoData();
      } else {
        _refreshController.loadComplete();
      }
    }
  }

  _getUserInfo() {
    SessionManager prefs = SessionManager();
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    prefs.getPassword().then((password) => print(password));
  }

  @override
  Widget build(BuildContext context) {
    print(_isLoading);
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: _appBar(context),
        body: !_isLoading
            ? _body()
            : Center(
                child: CircularProgressIndicator(),
              ),
        floatingActionButton: _floatingActionButton(context),
      ),
    );
  }

  _appBar(BuildContext context) {
    return AppBar(
      elevation: 4,
      centerTitle: false,
      leadingWidth: SizeConfig.blockSizeHorizontal * 35,
      leading: Image.asset('assets/images/app_logo.jpg'),
      actions: [
        IconButton(
          icon: Icon(FluentIcons.search_20_regular, color: Colors.black87),
          onPressed: () => Navigator.pushNamed(context, SearchScreen.routeName),
        ),
      ],
      bottom: _tabBar(),
    );
  }

  _tabBar() {
    return TabBar(
      // onTap: (index) async => _fetchData(getEndpoint(index)),
      controller: _tabController,
      isScrollable: true,
      labelColor: Colors.black87,
      unselectedLabelColor: Colors.black54,
      labelStyle: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 3.3),
      tabs: tabs,
    );
  }

  _body() {
    return TabBarView(
      controller: _tabController,
      children: tabs.map((Tab tab) {
        return _recentQuestions(tab.text);
      }).toList(),
    );
  }

  _floatingActionButton(BuildContext context) {
    return FloatingActionButton(
      elevation: 0,
      child: Icon(FluentIcons.add_12_filled),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => AskQuestionScreen(),
        ),
      ),
    );
  }

  Widget _recentQuestions(String endpoint) {
    return swipeToRefresh(
      context,
      refreshController: _refreshController,
      onRefresh: () => _onRefresh(endpoint),
      onLoading: () => _onLoading(getEndpoint(_tabController.index)),
      child: ListView.builder(
        itemCount: _questions.length,
        itemBuilder: (ctx, i) => PostListItem(question: _questions[i]),
      ),
    );
  }

  String getEndpoint(int index) {
    switch (index) {
      case 0:
        return 'recentQuestions';
        break;
      case 1:
        return 'mostAnsweredQuestions';
        break;
      case 2:
        return 'mostAnsweredQuestions';
        break;
      case 3:
        return 'mostVisitedQuestions';
        break;
      case 4:
        return 'mostVotedQuestions';
        break;
      case 5:
        return 'noAnsweredQuestions';
        break;
    }
    return 'recentQuestions';
  }
}
