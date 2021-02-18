import 'package:provider/provider.dart';
import 'package:zapytaj/config/size_config.dart';
import 'package:zapytaj/models/user.dart';
import 'package:zapytaj/providers/auth_provider.dart';
import 'package:zapytaj/services/api_repository.dart';
import 'package:zapytaj/widgets/appbar_leading_button.dart';
import 'package:zapytaj/widgets/user_follow_tile.dart';
import 'package:flutter/material.dart';

class FollowingFollowersScreen extends StatefulWidget {
  static const routeName = "following_followers_screen";

  @override
  _FollowingFollowersScreenState createState() =>
      _FollowingFollowersScreenState();
}

class _FollowingFollowersScreenState extends State<FollowingFollowersScreen> {
  AuthProvider authProvider;
  List<User> _following = [];
  List<User> _followers = [];

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthProvider>(context, listen: false);

    _getUserFollowing();
    _getUserFollowers();
  }

  _getUserFollowing() async {
    await ApiRepository.getUserFollowing(context, userId: authProvider.user.id)
        .then((following) {
      setState(() {
        _following = following;
      });
    });
  }

  _getUserFollowers() async {
    await ApiRepository.getUserFollowers(context, userId: authProvider.user.id)
        .then((followers) {
      setState(() {
        _followers = followers;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _appBar(),
        body: _body(),
      ),
    );
  }

  _appBar() {
    return AppBar(
      elevation: 4,
      title: Text('John Doe', style: TextStyle(color: Colors.black)),
      leading: AppBarLeadingButton(),
      centerTitle: true,
      bottom: _tabBar(),
    );
  }

  _tabBar() {
    return TabBar(
      labelColor: Colors.black87,
      unselectedLabelColor: Colors.black54,
      labelStyle: TextStyle(
          fontSize: SizeConfig.safeBlockHorizontal * 4,
          fontWeight: FontWeight.w600),
      tabs: [
        Tab(
          text: '${_followers.length == 0 ? '' : _followers.length} Followers',
        ),
        Tab(
          text: '${_following.length == 0 ? '' : _following.length} Following',
        ),
      ],
    );
  }

  _body() {
    return TabBarView(
      children: [
        _usersList(_followers),
        _usersList(_following),
      ],
    );
  }

  _usersList(List<User> users) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        vertical: SizeConfig.blockSizeVertical * 3,
        horizontal: SizeConfig.blockSizeHorizontal * 5,
      ),
      itemCount: users.length,
      itemBuilder: (ctx, i) => UserFollowTile(user: users[i]),
    );
  }
}
