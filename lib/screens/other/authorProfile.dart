import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:provider/provider.dart';
import 'package:zapytaj/config/size_config.dart';
import 'package:zapytaj/models/user.dart';
import 'package:zapytaj/providers/auth_provider.dart';
import 'package:zapytaj/screens/other/askQuestion.dart';
import 'package:zapytaj/services/api_repository.dart';
import 'package:zapytaj/utils/utils.dart';
import 'package:zapytaj/widgets/default_button.dart';
import 'package:flutter/material.dart';

class AuthorProfile extends StatefulWidget {
  final User author;

  const AuthorProfile({Key key, this.author}) : super(key: key);

  @override
  _AuthorProfileState createState() => _AuthorProfileState();
}

class _AuthorProfileState extends State<AuthorProfile>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  bool _isFollowing = false;

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
    _tabController = new TabController(length: 2, vsync: this);

    _checkIfIsFollowing();
  }

  _checkIfIsFollowing() async {
    AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);
    await ApiRepository.checkIfIsFollowing(
      context,
      userId: auth.user.id,
      followerId: widget.author.id,
    ).then((isFollowing) {
      setState(() {
        _isFollowing = isFollowing;
      });
    });
  }

  _followUser() async {
    AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);
    await ApiRepository.followOrUnfollowUser(
      context,
      userId: auth.user.id,
      followerId: widget.author.id,
    ).then((isFollowing) {
      setState(() {
        _isFollowing = isFollowing;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _body(context),
    );
  }

  _body(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCoverAndUserInfo(context),
              SizedBox(height: SizeConfig.blockSizeVertical * 2.5),
              _buildBioText(context),
              SizedBox(height: SizeConfig.blockSizeVertical * 2.5),
              _buildAskButton(),
              SizedBox(height: SizeConfig.blockSizeVertical * 5),
              _buildFollowingAndFollowersRow(context),
              SizedBox(height: SizeConfig.blockSizeVertical * 2.5),
              _buildInfoContainers(context),
              SizedBox(height: SizeConfig.blockSizeVertical * 5),
            ],
          ),
        ),
        _tabBar(),
        _tabBarBody(),
      ],
    );
  }

  _tabBar() {
    return SizedBox(
      height: 75,
      child: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(Icons.directions_bike),
            ),
            Tab(
              icon: Icon(
                Icons.directions_car,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _tabBarBody() {
    return Flexible(
      fit: FlexFit.loose,
      child: TabBarView(
        controller: _tabController,
        children: [
          // first tab bar view widget
          Container(
            color: Colors.red,
            child: Center(
              child: Text(
                'Bike',
              ),
            ),
          ),

          // second tab bar viiew widget
          Container(
            color: Colors.pink,
            child: Center(
              child: Text(
                'Car',
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildCoverAndUserInfo(BuildContext context) {
    return Stack(
      children: [
        _buildCoverImage(),
        Padding(
          padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBackButton(context),
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
    );
  }

  _buildCoverImage() {
    return Stack(
      children: [
        widget.author.cover == null
            ? Image.asset(
                'assets/images/cover_image.png',
                width: double.infinity,
                height: SizeConfig.blockSizeVertical * 30,
                fit: BoxFit.cover,
              )
            : Image.network(
                '${ApiRepository.COVER_IMAGES_PATH}${widget.author.cover}',
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

  _buildBackButton(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.chevron_left, color: Colors.white),
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
                child: widget.author.avatar == null
                    ? Image.asset('assets/images/user_icon.png')
                    : Image.network(
                        '${ApiRepository.AVATAR_IMAGES_PATH}${widget.author.avatar}',
                        width: double.infinity,
                        height: SizeConfig.blockSizeVertical * 30,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                left: SizeConfig.blockSizeHorizontal * 16,
                bottom: SizeConfig.blockSizeVertical,
              ),
              child: CircleAvatar(
                child: Icon(
                  Icons.done_sharp,
                  color: Colors.white,
                  size: SizeConfig.blockSizeHorizontal * 4,
                ),
                backgroundColor: Theme.of(context).primaryColor,
                maxRadius: SizeConfig.blockSizeHorizontal * 2.5,
              ),
            ),
          ),
        ),
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
          SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          widget.author.displayname,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: SizeConfig.safeBlockHorizontal * 4.1,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }

  _buildUserRole() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 2.4,
        vertical: SizeConfig.blockSizeVertical * 0.9,
      ),
      decoration: BoxDecoration(
        color: colorConvert(widget.author.badge.color),
        borderRadius: BorderRadius.circular(
          SizeConfig.blockSizeHorizontal * 0.7,
        ),
      ),
      child: Text(
        widget.author.badge.name,
        style: TextStyle(
          color: Colors.white,
          fontSize: SizeConfig.safeBlockHorizontal * 3.3,
        ),
      ),
    );
  }

  _buildFollowButton() {
    return InkWell(
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
    );
  }

  _buildBioText(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.author.description != null ? widget.author.description : '',
            maxLines: 3,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: SizeConfig.safeBlockHorizontal * 3.6,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          widget.author.description != null
              ? InkWell(
                  onTap: () => showCustomEmptyDialog(
                    context,
                    body: Text(
                      widget.author.description,
                      style: TextStyle(
                        fontSize: SizeConfig.safeBlockHorizontal * 3.6,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ),
                  child: Text(
                    'more',
                    style: TextStyle(
                      fontSize: SizeConfig.safeBlockHorizontal * 3.6,
                      color: Theme.of(context).primaryColor,
                      height: 1.4,
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  _buildAskButton() {
    return DefaultButton(
      text: 'Ask ${widget.author.displayname}',
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AskQuestionScreen(askAuthor: true),
        ),
      ),
    );
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
          _buildFollowCount(context, text: 'Followers', count: 0),
          _buildFollowCount(context, text: 'Following', count: 1),
        ],
      ),
    );
  }

  _buildFollowCount(BuildContext context, {String text, int count}) {
    return Row(
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
                  value: widget.author.questions,
                ),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 6),
                _buildInfoContainer(
                  icon: Icon(
                    FluentIcons.chat_bubbles_question_20_filled,
                    size: SizeConfig.blockSizeHorizontal * 7,
                    color: Colors.black54,
                  ),
                  label: 'Answers',
                  value: widget.author.answers,
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
                    value: 4),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 6),
                _buildInfoContainer(
                  icon: Icon(
                    FluentIcons.trophy_20_filled,
                    size: SizeConfig.blockSizeHorizontal * 7,
                    color: Colors.orange,
                  ),
                  label: 'Points',
                  value: widget.author.points,
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
