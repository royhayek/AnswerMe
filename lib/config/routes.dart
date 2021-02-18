import 'package:zapytaj/screens/auth/forgotPassword.dart';
import 'package:zapytaj/screens/auth/login.dart';
import 'package:zapytaj/screens/auth/register.dart';
import 'package:zapytaj/screens/landing/onboarding.dart';
import 'package:zapytaj/screens/landing/splash.dart';
import 'package:zapytaj/screens/other/editProfile.dart';
import 'package:zapytaj/screens/other/followingFollowers.dart';
import 'package:zapytaj/screens/other/information.dart';
import 'package:zapytaj/screens/other/notifications.dart';
import 'package:zapytaj/screens/other/search.dart';
import 'package:zapytaj/screens/tabsScreen.dart';
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
};
