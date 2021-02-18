import 'package:zapytaj/config/app_config.dart';
import 'package:zapytaj/providers/app_provider.dart';
import 'package:zapytaj/providers/auth_provider.dart';
import 'package:zapytaj/screens/auth/login.dart';
import 'package:zapytaj/screens/landing/onboarding.dart';
import 'package:zapytaj/config/size_config.dart';
import 'package:zapytaj/screens/tabsScreen.dart';
import 'package:zapytaj/utils/session_manager.dart';
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
                  .loginUser(context, user.username, password)
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
    // Future.delayed(Duration(seconds: 3), () {
    Navigator.pushReplacementNamed(context, OnBoardingScreen.routeName);
    // }
  }

  _navigateToLoginScreen() {
    // Future.delayed(Duration(seconds: 3), () {
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    // });
  }

  _navigateToTabsScreen() {
    // Future.delayed(Duration(seconds: 3), () {
    Navigator.pushReplacementNamed(context, TabsScreen.routeName);
    // });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          APP_NAME,
          style: TextStyle(
            fontFamily: 'Trueno',
            fontSize: SizeConfig.safeBlockHorizontal * 7,
          ),
        ),
      ),
    );
  }
}
