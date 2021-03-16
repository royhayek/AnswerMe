import 'dart:async';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:toast/toast.dart';
import 'package:zapytaj/config/AdmobConfig.dart';
import 'package:zapytaj/config/AppConfig.dart';
import 'package:zapytaj/models/question.dart';
import 'package:zapytaj/providers/AppProvider.dart';
import 'package:zapytaj/providers/AuthProvider.dart';
import 'package:zapytaj/screens/other/AskQuestion.dart';
import 'package:zapytaj/screens/other/UserProfile.dart';
import 'package:zapytaj/screens/other/QuestionDetail.dart';
import 'package:zapytaj/screens/other/Search.dart';
import 'package:zapytaj/services/ApiRepository.dart';
import 'package:zapytaj/utils/NotificationBloc.dart';
import 'package:zapytaj/utils/utils.dart';
import 'package:zapytaj/widgets/QuestionListItem.dart';

import '../../config/SizeConfig.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  StreamSubscription<Map> _notificationSubscription;
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
    _notificationSubscription = NotificationsBloc.instance.notificationStream
        .listen(_performActionOnNotification);
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
    _notificationSubscription.cancel();
    _tabController.dispose();
    super.dispose();
  }

  _setQuestionsInProvider(String endpoint) async {
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
  }

  _performActionOnNotification(Map<String, dynamic> message) async {
    if (message['data']['question_id'] != null)
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QuestionDetailScreen(
            questionId: int.parse(message['data']['question_id']),
          ),
        ),
      );
    else if (message['data']['author_id'] != null)
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => UserProfile(
            authorId: int.parse(message['data']['author_id']),
          ),
        ),
      );
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
        _setQuestionsInProvider(endpoint);
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
      title: Row(
        children: [
          Image.asset(
            'assets/images/app_icon.jpg',
            width: SizeConfig.blockSizeHorizontal * 13,
          ),
          Text(
            APP_NAME,
            style: TextStyle(
              fontFamily: 'Trueno',
              fontSize: SizeConfig.safeBlockHorizontal * 4.8,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
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
      tabs: tabs,
      controller: _tabController,
      isScrollable: true,
      labelColor: Colors.black87,
      indicatorWeight: 5.0,
      unselectedLabelColor: Colors.black54,
      labelStyle: TextStyle(
        fontSize: SizeConfig.safeBlockHorizontal * 3.3,
        fontWeight: FontWeight.w600,
      ),
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
      onPressed: () {
        if (authProvider.user != null && authProvider.user.id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => AskQuestionScreen(),
            ),
          );
        } else {
          Toast.show(
            'You have to login to ask questions',
            context,
            duration: 2,
          );
        }
      },
    );
  }

  Widget _recentQuestions(String endpoint) {
    AdmobBanner admobBanner = AdmobBanner(
      adUnitId: AdmobConfig.bannerAdUnitId,
      adSize: AdmobBannerSize.BANNER,
    );

    return swipeToRefresh(
      context,
      refreshController: _refreshController,
      onRefresh: () => _onRefresh(endpoint),
      onLoading: () => _onLoading(getEndpoint(_tabController.index)),
      child: ListView.builder(
        itemCount: _questions.length,
        itemBuilder: (ctx, i) {
          return Column(
            children: [
              i != 0 && (i == 1 || (i - 1) % 5 == 0)
                  ? Container(
                      width: double.infinity,
                      color: Colors.white,
                      alignment: Alignment.center,
                      child: admobBanner,
                      margin: EdgeInsets.only(
                        bottom: SizeConfig.blockSizeVertical * 0.5,
                      ),
                    )
                  : Container(),
              QuestionListItem(
                question: _questions[i],
                addToFav: _addToFavorite,
                removeFromFav: _removeFromFavorite,
                endpoint: getEndpoint(_selectedIndex),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget _recentQuestions(String endpoint) {
  //   return swipeToRefresh(
  //     context,
  //     refreshController: _refreshController,
  //     onRefresh: () => _onRefresh(endpoint),
  //     onLoading: () => _onLoading(getEndpoint(_tabController.index)),
  //     child: ListView.builder(
  //       itemCount: _questions.length + (_isAdLoaded ? 1 : 0),
  //       itemBuilder: (ctx, i) {
  //         if (_isAdLoaded && i == _kAdIndex) {
  //           return Container(
  //             child: AdWidget(ad: _ad),
  //             width: _ad.size.width.toDouble(),
  //             height: 72.0,
  //             alignment: Alignment.center,
  //           );
  //         } else {
  //           return PostListItem(
  //             question: _questions[i],
  //             addToFav: _addToFavorite,
  //             removeFromFav: _removeFromFavorite,
  //             endpoint: getEndpoint(_selectedIndex),
  //           );
  //         }
  //       },
  //     ),
  //   );
  // }

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
