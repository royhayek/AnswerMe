import 'package:provider/provider.dart';
import 'package:zapytaj/providers/AuthProvider.dart';
import 'package:zapytaj/screens/other/UserProfile.dart';
import 'package:zapytaj/services/ApiRepository.dart';
import 'package:zapytaj/utils/SessionManager.dart';
import 'package:zapytaj/config/AppConfig.dart';
import 'package:zapytaj/config/SizeConfig.dart';
import 'package:zapytaj/screens/auth/Login.dart';
import 'package:zapytaj/screens/other/EditProfile.dart';
import 'package:zapytaj/screens/other/FollowingFollowers.dart';
import 'package:zapytaj/screens/other/Information.dart';
import 'package:zapytaj/screens/other/Notifications.dart';
import 'package:zapytaj/utils/utils.dart';
import 'package:zapytaj/widgets/SettingsListItem.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:launch_review/launch_review.dart';
import 'package:share/share.dart';
import 'dart:io' show Platform;

class SettingsScreen extends StatelessWidget {
  _rateApp() {
    LaunchReview.launch(iOSAppId: IOS_APP_ID);
  }

  _shareApp() {
    if (Platform.isAndroid) {
      Share.share('$SHARE_TEXT \n $ANDROID_SHARE_URL');
    } else if (Platform.isIOS) {
      Share.share('$SHARE_TEXT \n $IOS_SHARE_URL');
    }
  }

  _logout(BuildContext context, AuthProvider auth) async {
    SessionManager pref = SessionManager();
    Navigator.pushNamedAndRemoveUntil(
      context,
      LoginScreen.routeName,
      (route) => false,
    );
    await pref.cleaUser();
    await auth.clearUser();
  }

  _deleteAccount(BuildContext context, AuthProvider auth) async {
    showConfirmationDialog(
      context,
      text: 'Are you sure you want to delete your account?',
      yes: () async {
        await ApiRepository.deleteAccount(context, userId: auth.user.id)
            .then((value) {
          _logout(context, auth);
        });
      },
      no: () => Navigator.pop(context),
    );
  }

  _navigateToAuthorProfile(BuildContext context) {
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => UserProfile(authorId: authProvider.user.id),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.black.withOpacity(0.2)),
    );
    return Scaffold(
      appBar: _appBar(),
      body: _body(context),
    );
  }

  _appBar() {
    return AppBar(
      title: Text('Settings', style: TextStyle(color: Colors.black)),
    );
  }

  _body(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(height: SizeConfig.blockSizeVertical * 4),
                _buildUserImage(context),
                SizedBox(height: SizeConfig.blockSizeVertical * 2),
                _buildUserName(context),
                SizedBox(height: SizeConfig.blockSizeVertical * 3),
                _buildButtonsRow(context),
                SizedBox(height: SizeConfig.blockSizeVertical * 4),
                _buildScreenButtonsList(context),
              ],
            ),
          ),
          _buildBottomScreenButtonsList(context),
        ],
      ),
    );
  }

  _buildUserImage(BuildContext context) {
    return InkWell(
      onTap: () => _navigateToAuthorProfile(context),
      child: Consumer<AuthProvider>(builder: (context, auth, child) {
        if (auth.user == null || auth.user.avatar == null) {
          return CircleAvatar(
            backgroundImage: AssetImage('assets/images/user_icon.png'),
            backgroundColor: Colors.transparent,
            maxRadius: SizeConfig.blockSizeHorizontal * 9,
          );
        } else {
          return CircleAvatar(
            backgroundImage: NetworkImage(
              '${ApiRepository.AVATAR_IMAGES_PATH}${auth.user.avatar}',
            ),
            backgroundColor: Colors.transparent,
            maxRadius: SizeConfig.blockSizeHorizontal * 9,
          );
        }
      }),
    );
  }

  _buildUserName(BuildContext context) {
    return InkWell(
      onTap: () => _navigateToAuthorProfile(context),
      child: Consumer<AuthProvider>(builder: (context, auth, child) {
        if (auth.user == null || auth.user.displayname == null) {
          return GestureDetector(
            onTap: () => Navigator.pushNamedAndRemoveUntil(
                context, LoginScreen.routeName, (route) => false),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FluentIcons.person_20_filled,
                  size: SizeConfig.blockSizeHorizontal * 5,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 2),
                Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: SizeConfig.safeBlockHorizontal * 4,
                  ),
                ),
              ],
            ),
          );
        } else {
          return Text(
            auth.user.displayname,
            style: TextStyle(
              color: Colors.black87,
              fontSize: SizeConfig.safeBlockHorizontal * 4.6,
            ),
          );
        }
      }),
    );
  }

  _buildButtonsRow(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) =>
          auth.user == null || auth.user.username == null
              ? Container()
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _circularButton(
                      count: auth.user.followers,
                      icon: FluentIcons.people_community_16_filled,
                      onPressed: () => Navigator.pushNamed(
                        context,
                        FollowingFollowersScreen.routeName,
                      ),
                    ),
                    _circularButton(
                      count: auth.user.questions,
                      icon: FluentIcons.clipboard_20_filled,
                      onPressed: () => _navigateToAuthorProfile(context),
                    ),
                    _circularButton(
                      count: auth.user.notifications,
                      icon: FluentIcons.alert_20_filled,
                      onPressed: () => Navigator.pushNamed(
                        context,
                        NotificationsScreen.routeName,
                      ),
                    ),
                  ],
                ),
    );
  }

  _buildScreenButtonsList(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) => ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: [
          auth.user == null || auth.user.username == null
              ? Container()
              : SettingsListItem(
                  text: 'Edit Profile',
                  arrow: true,
                  onTap: () =>
                      Navigator.pushNamed(context, EditProfileScreen.routeName),
                ),
          SettingsListItem(
            text: 'About Us',
            arrow: true,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => InformationScreen(title: 'About Us'),
              ),
            ),
          ),
          SettingsListItem(
            text: 'Share the app',
            arrow: false,
            onTap: () => _shareApp(),
          ),
          SettingsListItem(
            text: 'FAQ',
            arrow: true,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => InformationScreen(title: 'FAQ'),
              ),
            ),
          ),
          SettingsListItem(
            text: 'Badges & Points',
            arrow: true,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => InformationScreen(title: 'Badges & Points'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildBottomScreenButtonsList(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) => Padding(
        padding: EdgeInsets.only(
          top: SizeConfig.blockSizeVertical * 1.6,
        ),
        child: Container(
          padding: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 2),
          color: Colors.white,
          child: ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              SettingsListItem(
                text: 'Contact Us',
                arrow: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => InformationScreen(title: 'Contact Us'),
                  ),
                ),
              ),
              SettingsListItem(
                text: 'Rate this app',
                arrow: false,
                onTap: () => _rateApp(),
              ),
              SettingsListItem(
                text: 'Privacy Policy',
                arrow: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) =>
                        InformationScreen(title: 'Privacy Policy'),
                  ),
                ),
              ),
              SettingsListItem(
                text: 'Terms and Conditions',
                arrow: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) =>
                        InformationScreen(title: 'Terms and Conditions'),
                  ),
                ),
              ),
              auth.user == null || auth.user.username == null
                  ? Container()
                  : SettingsListItem(
                      text: 'Logout',
                      arrow: true,
                      color: Theme.of(context).primaryColor,
                      onTap: () => _logout(context, auth),
                    ),
              auth.user == null || auth.user.username == null
                  ? Container()
                  : SettingsListItem(
                      text: 'Delete Account',
                      arrow: false,
                      color: Colors.red,
                      onTap: () => _deleteAccount(context, auth),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  _circularButton({IconData icon, int count, Function onPressed}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30),
              ),
              width: SizeConfig.blockSizeHorizontal * 11,
              height: SizeConfig.blockSizeHorizontal * 11,
              child: Icon(
                icon,
                size: SizeConfig.blockSizeHorizontal * 3.8,
                color: Colors.black54,
              ),
            ),
            onTap: () => onPressed(),
          ),
          SizedBox(width: SizeConfig.blockSizeHorizontal * 4),
          Text(count.toString(), style: TextStyle(color: Colors.black54))
        ],
      ),
    );
  }
}
