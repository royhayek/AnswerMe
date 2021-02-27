import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:zapytaj/config/app_config.dart';
import 'package:zapytaj/models/question.dart';
import 'package:zapytaj/providers/app_provider.dart';
import 'package:zapytaj/providers/auth_provider.dart';
import 'package:zapytaj/screens/other/askQuestion.dart';
import 'package:zapytaj/screens/other/search.dart';
import 'package:zapytaj/services/api_repository.dart';
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
  int _selectedIndex = 0;
  AuthProvider authProvider;
  AppProvider appProvider;
  List<Question> _questions = [];
  int _page;
  bool _shouldStopRequests;
  bool _waitForNextRequest;
  bool _isLoading = true;

  final List<Tab> tabs = <Tab>[
    Tab(text: 'Recent Questions'),
    Tab(text: 'Most Answered'),
    Tab(text: 'Most Visited'),
    Tab(text: 'Most Voted'),
    Tab(text: 'No Answers'),
  ];
  // Tab(text: 'Bump Question'),

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    appProvider = Provider.of<AppProvider>(context, listen: false);

    _tabController = new TabController(vsync: this, length: tabs.length);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
        _checkIfDataExists(getEndpoint(_selectedIndex)).then((exist) async {
          if (!exist) await _fetchData(getEndpoint(_selectedIndex));
        });
        print("Selected Index: " + _tabController.index.toString());
      } else {
        print(
            "tab is animating. from active (getting the index) to inactive(getting the index) ");
      }
    });

    if (appProvider.recentQuestions.isNotEmpty) {
      _questions = appProvider.recentQuestions;
      setState(() {
        _isLoading = false;
      });
    } else
      _fetchData('recentQuestions');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _fetchData(String endpoint) async {
    setState(() {
      _isLoading = true;
      _questions = [];
      _page = 1;
    });

    _shouldStopRequests = false;
    _waitForNextRequest = false;

    await _getQuestions(endpoint);

    setState(() {
      _isLoading = false;
    });
  }

  Future<bool> _checkIfDataExists(String endpoint) async {
    switch (endpoint) {
      case 'recentQuestions':
        if (appProvider.recentQuestions.isNotEmpty) {
          setState(() {
            _questions = appProvider.recentQuestions;
          });
          return true;
        } else
          return false;
        break;
      case 'mostAnsweredQuestions':
        if (appProvider.mostAnsweredQuestions.isNotEmpty) {
          setState(() {
            _questions = appProvider.mostAnsweredQuestions;
          });
          return true;
        } else
          return false;
        break;
      case 'mostVisitedQuestions':
        if (appProvider.mostVisitedQuestions.isNotEmpty) {
          setState(() {
            _questions = appProvider.mostVisitedQuestions;
          });
          return true;
        } else
          return false;
        break;
      case 'mostVotedQuestions':
        if (appProvider.mostVotedQuestions.isNotEmpty) {
          setState(() {
            _questions = appProvider.mostVotedQuestions;
          });
          return true;
        } else
          return false;
        break;
      case 'noAnsweredQuestions':
        if (appProvider.noAnswersQuestions.isNotEmpty) {
          setState(() {
            _questions = appProvider.noAnswersQuestions;
          });
          return true;
        } else
          return false;
        break;
      default:
        return false;
    }
  }

  _getQuestions(String endpoint) async {
    if (_shouldStopRequests) return;
    if (_waitForNextRequest) return;
    _waitForNextRequest = true;
    await ApiRepository.getRecentQuestions(context, endpoint,
            offset: PER_PAGE,
            page: _page,
            userId: authProvider.user != null ? authProvider.user.id : 0)
        .then((questions) async {
      setState(() {
        _page = _page + 1;
        _waitForNextRequest = false;
        if (questions.data != null) _questions.addAll(questions.data.toList());
      });
      switch (endpoint) {
        case 'recentQuestions':
          await appProvider.setRecentQuestions(_questions);
          break;
        case 'mostAnsweredQuestions':
          await appProvider.setMostAnsweredQuestions(_questions);
          break;
        case 'mostVisitedQuestions':
          await appProvider.setMostVisitedQuestions(_questions);
          break;
        case 'mostVotedQuestions':
          await appProvider.setMostVotedQuestions(_questions);
          break;
        case 'noAnsweredQuestions':
          await appProvider.setNoAnswersQuestions(_questions);
          break;
        default:
      }
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
      appBar: _appBar(context),
      body: !_isLoading
          ? _body()
          : Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: _floatingActionButton(context),
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
      indicatorWeight: 5.0,
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
        itemBuilder: (ctx, i) => PostListItem(
          question: _questions[i],
          addToFav: _addToFavorite,
          removeFromFav: _removeFromFavorite,
        ),
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
      // case 2:
      //   return 'mostAnsweredQuestions';
      //   break;
      case 2:
        return 'mostVisitedQuestions';
        break;
      case 3:
        return 'mostVotedQuestions';
        break;
      case 4:
        return 'noAnsweredQuestions';
        break;
    }
    return 'recentQuestions';
  }
}
