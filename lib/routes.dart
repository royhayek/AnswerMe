import 'package:zapytaj/screens/auth/ForgotPassword.dart';
import 'package:zapytaj/screens/auth/Login.dart';
import 'package:zapytaj/screens/auth/Register.dart';
import 'package:zapytaj/screens/landing/Onboarding.dart';
import 'package:zapytaj/screens/landing/Splash.dart';
import 'package:zapytaj/screens/other/EditProfile.dart';
import 'package:zapytaj/screens/other/FollowingFollowers.dart';
import 'package:zapytaj/screens/other/Information.dart';
import 'package:zapytaj/screens/other/Notifications.dart';
import 'package:zapytaj/screens/other/QuestionPosted.dart';
import 'package:zapytaj/screens/other/Search.dart';
import 'package:zapytaj/screens/Tabs.dart';
import 'package:flutter/widgets.dart';

// We use name route
// All our routes will be available here
final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  OnBoardingScreen.routeName: (context) => OnBoardingScreen(),
  TabsScreen.routeName: (context) => TabsScreen(),
  LoginScreen.routeName: (context) => LoginScreen(),
  RegisterScreen.routeName: (context) => RegisterScreen(),
  ForgotPasswordScreen.routeName: (context) => ForgotPasswordScreen(),
  SearchScreen.routeName: (context) => SearchScreen(),
  FollowingFollowersScreen.routeName: (context) => FollowingFollowersScreen(),
  NotificationsScreen.routeName: (context) => NotificationsScreen(),
  EditProfileScreen.routeName: (context) => EditProfileScreen(),
  InformationScreen.routeName: (context) => InformationScreen(),
  QuestionPostedScreen.routeName: (context) => QuestionPostedScreen(),
};
