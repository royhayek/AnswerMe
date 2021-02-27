import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:provider/provider.dart';
import 'package:zapytaj/config/size_config.dart';
import 'package:zapytaj/models/question.dart';
import 'package:zapytaj/models/user.dart';
import 'package:zapytaj/providers/auth_provider.dart';
import 'package:zapytaj/screens/other/askQuestion.dart';
import 'package:zapytaj/screens/other/followingFollowers.dart';
import 'package:zapytaj/services/api_repository.dart';
import 'package:zapytaj/utils/utils.dart';
import 'package:zapytaj/widgets/default_button.dart';
import 'package:flutter/material.dart';
import 'package:zapytaj/widgets/expandable_text.dart';
import 'package:zapytaj/widgets/post_list_item.dart';

class AuthorProfile extends StatefulWidget {
  final User author;

  const AuthorProfile({Key key, this.author}) : super(key: key);

  @override
  _AuthorProfileState createState() => _AuthorProfileState();
}

class _AuthorProfileState extends State<AuthorProfile>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  AuthProvider _authProvider;
  bool _isFollowing = false;
  bool isLoading = true;
  bool _isLoading = true;
  List<Question> _questions = [];
  var _scrollViewController = ScrollController();
  var _listViewController = ScrollController();
  ScrollPhysics _scrollViewPhysics;
  ScrollPhysics _listViewPhysics = NeverScrollableScrollPhysics();
  User _author;
  int initPosition = 1;

  final List<Tab> _tabs = <Tab>[
    Tab(text: 'Questions'),
    Tab(text: 'Polls'),
    Tab(text: 'Favorite Questions'),
    Tab(text: 'Asked Questions'),
    // Tab(text: 'Followed Questions'),
    // Tab(text: 'Posts'),
  ];

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (_authProvider.user != null &&
        _authProvider.user.id == widget.author.id) {
      _tabs.add(Tab(text: 'Waiting Questions'));
      _tabController = new TabController(length: 5, vsync: this);
    } else {
      _tabController = new TabController(length: 4, vsync: this);
    }
    _tabController.addListener(onPositionChange);

    _scrollViewController.addListener(() {
      if (_scrollViewController.position.atEdge) {
        if (_scrollViewController.position.pixels == 0) {
          setState(() {
            _scrollViewPhysics = ScrollPhysics();
            _listViewPhysics = NeverScrollableScrollPhysics();
          });
        } else {
          setState(() {
            if (_scrollViewPhysics == NeverScrollableScrollPhysics())
              _scrollViewPhysics = NeverScrollableScrollPhysics();
            _listViewPhysics = ScrollPhysics();
          });
        }
      }
    });

    _listViewController.addListener(() {
      if (_listViewController.position.atEdge) {
        if (_listViewController.position.pixels == 0) {
          setState(() {
            _scrollViewPhysics = ScrollPhysics();
            _listViewPhysics = NeverScrollableScrollPhysics();
          });
        }
      }
    });

    _getUserInfo();
    _checkIfIsFollowing();
    _getQuestions('getUserQuestions');
  }

  onPositionChange() async {
    setState(() {
      _isLoading = true;
    });
    if (!_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          await _checkIfDataExist('getUserQuestions');
          break;
        case 1:
          await _checkIfDataExist('getUserPollQuestions');
          break;
        case 2:
          await _checkIfDataExist('getUserFavQuestions');
          break;
        case 3:
          await _checkIfDataExist('getUserAskedQuestions');
          break;
        case 4:
          await _checkIfDataExist('getUserWaitingQuestions');
          break;
      }
    }
  }

  @override
  void dispose() {
    _authProvider.clearProfileQuestions();
    super.dispose();
  }

  _getUserInfo() async {
    await ApiRepository.getUserInfo(context, userId: widget.author.id)
        .then((author) {
      setState(() {
        _author = author;
      });
    });
  }

  _checkIfIsFollowing() async {
    AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);
    await ApiRepository.checkIfIsFollowing(
      context,
      userId: auth.user != null ? auth.user.id : 0,
      followerId: widget.author.id,
    ).then((isFollowing) {
      setState(() {
        _isFollowing = isFollowing;
      });
    });

    setState(() {
      isLoading = false;
    });
  }

  _checkIfDataExist(String endpoint) async {
    switch (endpoint) {
      case 'getUserQuestions':
        if (_authProvider.questions.isNotEmpty) {
          setState(() {
            _questions = _authProvider.questions;
          });
        } else {
          await _getQuestions(endpoint);
        }
        break;
      case 'getUserPollQuestions':
        if (_authProvider.polls.isNotEmpty) {
          setState(() {
            _questions = _authProvider.polls;
          });
        } else {
          await _getQuestions(endpoint);
        }
        break;
      case 'getUserFavQuestions':
        if (_authProvider.favorites.isNotEmpty) {
          setState(() {
            _questions = _authProvider.favorites;
          });
        } else {
          await _getQuestions(endpoint);
        }
        break;
      case 'getUserAskedQuestions':
        if (_authProvider.asked.isNotEmpty) {
          setState(() {
            _questions = _authProvider.asked;
          });
        } else {
          await _getQuestions(endpoint);
        }
        break;

      case 'getUserWaitingQuestions':
        if (_authProvider.waiting.isNotEmpty) {
          setState(() {
            _questions = _authProvider.waiting;
          });
        } else {
          await _getQuestions(endpoint);
        }
        break;
    }

    setState(() {
      _isLoading = false;
    });
  }

  _getQuestions(String endpoint) async {
    await ApiRepository.getProfileQuestions(context, endpoint, widget.author.id)
        .then((questions) async {
      setState(() {
        _questions = questions;
        switch (endpoint) {
          case 'getUserQuestions':
            _authProvider.setQuestions(questions);
            break;
          case 'getUserPollQuestions':
            _authProvider.setPolls(questions);
            break;
          case 'getUserFavQuestions':
            _authProvider.setFavorites(questions);
            break;
          case 'getUserAskedQuestions':
            _authProvider.setAsked(questions);
            break;
          case 'getUserWaitingQuestions':
            _authProvider.setWaiting(questions);
            break;
        }
      });
    });

    setState(() {
      _isLoading = false;
    });
  }

  _followUser() async {
    AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);
    await ApiRepository.followOrUnfollowUser(
      context,
      userId: auth.user.id,
      followerId: _author.id,
    ).then((isFollowing) {
      setState(() {
        _isFollowing = isFollowing;
      });
    });
  }

  final controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _body(context),
    );
  }

  _body(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            controller: _scrollViewController,
            physics: _scrollViewPhysics,
            child: Column(
              children: [
                Container(
                  height: SizeConfig.screenHeight * 1.88,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCoverAndUserInfo(context),
                      SizedBox(height: SizeConfig.blockSizeVertical * 2.5),
                      _buildBioText(context),
                      SizedBox(height: SizeConfig.blockSizeVertical * 4),
                      _buildAskButton(),
                      _buildFollowingAndFollowersRow(context),
                      SizedBox(height: SizeConfig.blockSizeVertical * 4),
                      _buildInfoContainers(context),
                      SizedBox(height: SizeConfig.blockSizeVertical * 4),
                      _tabBar(),
                      _tabBarBody(),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  _tabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      indicatorWeight: 5.0,
      labelColor: Colors.black87,
      unselectedLabelColor: Colors.black54,
      labelStyle: TextStyle(
        fontSize: SizeConfig.safeBlockHorizontal * 4,
        fontWeight: FontWeight.w600,
      ),
      tabs: _tabs,
    );
  }

  _tabBarBody() {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: _tabs.map((Tab tab) {
          return _recentQuestions();
        }).toList(),
      ),
    );
  }

  Widget _recentQuestions() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : _questions.isNotEmpty
            ? Container(
                color: Colors.grey.shade200,
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                    controller: _listViewController,
                    itemCount: _questions.length,
                    physics: _listViewPhysics,
                    itemBuilder: (ctx, i) => PostListItem(
                      question: _questions[i],
                    ),
                  ),
                ),
              )
            : Padding(
                padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No questions found',
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: SizeConfig.safeBlockHorizontal * 3.5),
                    )
                  ],
                ),
              );
  }

  _buildCoverAndUserInfo(BuildContext context) {
    return _author != null && _author.cover != null
        ? Stack(
            children: [
              _buildCoverImage(),
              Padding(
                padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBackButton(context, Colors.white),
                    SizedBox(height: SizeConfig.blockSizeVertical * 14),
                    Row(
                      children: [
                        _buildAvatarImage(context),
                        _buildUserInformation(context),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )
        : SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildBackButton(context, Colors.black),
                  Expanded(
                    child: Row(
                      children: [
                        _buildAvatarImage(context),
                        _buildUserInformation(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  _buildCoverImage() {
    return Stack(
      children: [
        _author.cover == null
            ? Image.asset(
                'assets/images/cover_image.png',
                width: double.infinity,
                height: SizeConfig.blockSizeVertical * 30,
                fit: BoxFit.cover,
              )
            : Image.network(
                '${ApiRepository.COVER_IMAGES_PATH}${_author.cover}',
                width: double.infinity,
                height: SizeConfig.blockSizeVertical * 30,
                fit: BoxFit.fill,
              ),
        Container(
          height: SizeConfig.blockSizeVertical * 30,
          color: Colors.black.withOpacity(0.6),
        ),
      ],
    );
  }

  _buildBackButton(BuildContext context, Color color) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.chevron_left, color: color),
        ),
      ],
    );
  }

  _buildAvatarImage(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockSizeHorizontal * 6,
          ),
          clipBehavior: Clip.hardEdge,
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: Colors.white),
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal),
            child: CircleAvatar(
              maxRadius: SizeConfig.blockSizeHorizontal * 11.5,
              backgroundColor: Colors.black54,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: _author != null && _author.avatar != null
                    ? Image.network(
                        '${ApiRepository.AVATAR_IMAGES_PATH}${_author.avatar}',
                        width: double.infinity,
                        height: SizeConfig.blockSizeVertical * 30,
                        fit: BoxFit.cover,
                      )
                    : Image.asset('assets/images/user_icon.png'),
              ),
            ),
          ),
        ),
        // Positioned.fill(
        //   child: Align(
        //     alignment: Alignment.bottomCenter,
        //     child: Padding(
        //       padding: EdgeInsets.only(
        //         left: SizeConfig.blockSizeHorizontal * 16,
        //         bottom: SizeConfig.blockSizeVertical,
        //       ),
        //       child: CircleAvatar(
        //         child: Icon(
        //           Icons.done_sharp,
        //           color: Colors.white,
        //           size: SizeConfig.blockSizeHorizontal * 4,
        //         ),
        //         backgroundColor: Theme.of(context).primaryColor,
        //         maxRadius: SizeConfig.blockSizeHorizontal * 2.5,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  _buildUserInformation(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(height: SizeConfig.blockSizeVertical * 5),
          _buildUserName(context),
          SizedBox(height: SizeConfig.blockSizeVertical),
          Row(
            children: [
              _buildUserRole(),
              SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
              _buildFollowButton(),
            ],
          ),
        ],
      ),
    );
  }

  _buildUserName(BuildContext context) {
    return _author != null && _author.displayname != null
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                _author.displayname,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: SizeConfig.safeBlockHorizontal * 4.1,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          )
        : Container();
  }

  _buildUserRole() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 2.4,
        vertical: SizeConfig.blockSizeVertical * 0.9,
      ),
      decoration: BoxDecoration(
        color: colorConvert(_author.badge.color),
        borderRadius: BorderRadius.circular(
          SizeConfig.blockSizeHorizontal * 0.7,
        ),
      ),
      child: Text(
        _author.badge.name,
        style: TextStyle(
          color: Colors.white,
          fontSize: SizeConfig.safeBlockHorizontal * 3.3,
        ),
      ),
    );
  }

  _buildFollowButton() {
    return _authProvider.user != null && _author.id != _authProvider.user.id
        ? InkWell(
            onTap: () => _followUser(),
            child: Container(
              height: SizeConfig.blockSizeVertical * 3.7,
              decoration: _isFollowing
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(width: 1, color: Colors.black54),
                    )
                  : BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(2),
                    ),
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockSizeHorizontal * 3,
                vertical: SizeConfig.blockSizeVertical * 0.5,
              ),
              child: Center(
                child: Text(
                  _isFollowing ? 'Unfollow' : 'Follow',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                    fontWeight: FontWeight.w400,
                    color: _isFollowing ? Colors.black54 : Colors.white,
                  ),
                ),
              ),
            ),
          )
        : Container();
  }

  _buildBioText(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExpandableText(
            _author.description != null ? _author.description : '',
            trimLines: 3,
            style: TextStyle(
              fontSize: SizeConfig.safeBlockHorizontal * 3.6,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  _buildAskButton() {
    return _authProvider.user != null && _author.id != _authProvider.user.id
        ? Column(
            children: [
              DefaultButton(
                text: 'Ask ${_author.displayname}',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AskQuestionScreen(
                      askAuthor: true,
                      authorId: _author.id,
                    ),
                  ),
                ),
              ),
              SizedBox(height: SizeConfig.blockSizeVertical * 5),
            ],
          )
        : Container();
  }

  _buildFollowingAndFollowersRow(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFollowCount(
            context,
            text: 'Followers',
            count: _author.followers,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) =>
                    FollowingFollowersScreen(authorId: _author.id, index: 0),
              ),
            ),
          ),
          _buildFollowCount(
            context,
            text: 'Following',
            count: _author.following,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) =>
                    FollowingFollowersScreen(authorId: _author.id, index: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildFollowCount(BuildContext context,
      {String text, int count, Function onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Expanded(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            overlappedUserImages(),
            SizedBox(width: SizeConfig.blockSizeHorizontal * 2),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: SizeConfig.safeBlockHorizontal * 3.8,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: SizeConfig.blockSizeVertical),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: SizeConfig.safeBlockHorizontal * 3.2,
                    color: Colors.black54,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget overlappedUserImages() {
    final overlap = 16.0;
    final items = [
      _userIconCircleAvatar(),
      _userIconCircleAvatar(),
      _userIconCircleAvatar(),
    ];

    List<Widget> stackLayers = List<Widget>.generate(items.length, (index) {
      return Padding(
        padding: EdgeInsets.fromLTRB(index.toDouble() * overlap, 0, 0, 0),
        child: items[index],
      );
    });

    return Stack(children: stackLayers);
  }

  _userIconCircleAvatar() {
    return CircleAvatar(
      child: CircleAvatar(
        backgroundImage: AssetImage('assets/images/user_icon.png'),
        backgroundColor: Colors.white,
        maxRadius: SizeConfig.blockSizeHorizontal * 4.1,
      ),
      maxRadius: SizeConfig.blockSizeHorizontal * 4.6,
      backgroundColor: Colors.white,
    );
  }

  _buildInfoContainers(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoContainer(
                  icon: Icon(
                    FluentIcons.receipt_20_filled,
                    size: SizeConfig.blockSizeHorizontal * 8,
                    color: Colors.blueAccent,
                  ),
                  label: 'Questions',
                  value: _author.questions,
                ),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 6),
                _buildInfoContainer(
                  icon: Icon(
                    FluentIcons.chat_bubbles_question_20_filled,
                    size: SizeConfig.blockSizeHorizontal * 7,
                    color: Colors.black54,
                  ),
                  label: 'Answers',
                  value: _author.answers,
                ),
              ],
            ),
            SizedBox(height: SizeConfig.blockSizeVertical * 3),
            Row(
              children: [
                _buildInfoContainer(
                    icon: Icon(
                      FluentIcons.chat_bubbles_question_24_filled,
                      size: SizeConfig.blockSizeHorizontal * 7,
                      color: Colors.green,
                    ),
                    label: 'Best Answer',
                    value: _author.bestAnswers),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 6),
                _buildInfoContainer(
                  icon: Icon(
                    FluentIcons.trophy_20_filled,
                    size: SizeConfig.blockSizeHorizontal * 7,
                    color: Colors.orange,
                  ),
                  label: 'Points',
                  value: _author.points,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _buildInfoContainer({Icon icon, String label, int value}) {
    return Expanded(
      child: Container(
        height: SizeConfig.blockSizeVertical * 10,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(SizeConfig.blockSizeHorizontal),
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockSizeHorizontal * 3,
              ),
              child: Container(
                width: SizeConfig.blockSizeHorizontal * 12,
                height: SizeConfig.blockSizeVertical * 7.2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    SizeConfig.blockSizeHorizontal,
                  ),
                ),
                child: icon,
              ),
            ),
            SizedBox(width: SizeConfig.blockSizeHorizontal),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: SizeConfig.safeBlockHorizontal * 5,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: SizeConfig.blockSizeVertical),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: SizeConfig.safeBlockHorizontal * 3.2,
                    color: Colors.black54,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
