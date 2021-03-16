import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:zapytaj/config/AppConfig.dart';
import 'package:zapytaj/providers/AppProvider.dart';
import 'package:zapytaj/providers/AuthProvider.dart';
import 'package:zapytaj/screens/auth/Login.dart';
import 'package:zapytaj/screens/landing/Onboarding.dart';
import 'package:zapytaj/config/SizeConfig.dart';
import 'package:zapytaj/screens/Tabs.dart';
import 'package:zapytaj/utils/SessionManager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = 'splash_screen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SessionManager prefs = SessionManager();

  @override
  void initState() {
    super.initState();
    _retrieveData();
    _checkIfFirstTime();
  }

  _retrieveData() async {
    if (Platform.isIOS) await Admob.requestTrackingAuthorization();
    AppProvider appProvider = Provider.of(context, listen: false);
    await appProvider.getSettings(context);
  }

  _checkIfFirstTime() async {
    bool firsttime = await prefs.getFirstTime();
    if (firsttime) {
      await prefs.setFirstTime(false);
      _navigateToOnBoardScreen();
    } else {
      _checkIfLoggedIn();
    }
  }

  _checkIfLoggedIn() async {
    bool loggedIn = await prefs.getLoggedIn();
    if (loggedIn) {
      AuthProvider authProvider =
          Provider.of<AuthProvider>(context, listen: false);
      await prefs.getUser().then(
            (user) => prefs.getPassword().then((password) {
              authProvider
                  .loginUser(context, user.email, password)
                  .then((user) async {
                if (user != null) _navigateToTabsScreen();
              });
            }),
          );
    } else {
      _navigateToLoginScreen();
    }
  }

  _navigateToOnBoardScreen() {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, OnBoardingScreen.routeName);
    });
  }

  _navigateToLoginScreen() {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    });
  }

  _navigateToTabsScreen() {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, TabsScreen.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/app_icon.jpg',
              width: SizeConfig.blockSizeHorizontal * 35,
            ),
            Text(
              APP_NAME,
              style: TextStyle(
                fontFamily: 'Trueno',
                fontSize: SizeConfig.safeBlockHorizontal * 7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
