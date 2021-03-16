import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData themeData = ThemeData(
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: Colors.grey.shade200,
    appBarTheme: appBarTheme(),
    textTheme: textTheme(),
  );
}

AppBarTheme appBarTheme() {
  return AppBarTheme(
    brightness: Brightness.light,
    color: Colors.white,
    elevation: 0.5,
    centerTitle: true,
  );
}

TextTheme textTheme() {
  return TextTheme(
      // headline2: TextStyle(
      //   color: Colors.black,
      //   fontSize: 15,
      // ),
      // headline3: TextStyle(
      //     fontFamily: 'Raleway',
      //     fontWeight: FontWeight.w500,
      //     fontSize: 20,
      //     color: Colors.black),
      // headline4: TextStyle(
      //   color: Colors.black,
      //   fontSize: 18,
      //   fontWeight: FontWeight.w500,
      // ),
      // subtitle1: TextStyle(
      //   fontSize: 17,
      //   color: Colors.black87,
      //   fontWeight: FontWeight.w600,
      // ),
      // subtitle2: TextStyle(
      //   fontWeight: FontWeight.bold,
      //   fontSize: 15,
      //   color: Colors.black.withOpacity(0.7),
      // ),
      // headline6: TextStyle(color: Colors.black),
      );
}
