import 'package:zapytaj/config/app_theme.dart';
import 'package:zapytaj/providers/app_provider.dart';
import 'package:zapytaj/providers/auth_provider.dart';
import 'package:zapytaj/screens/landing/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'config/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.white),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zapytaj',
      color: Colors.white,
      theme: AppTheme.themeData,
      initialRoute: SplashScreen.routeName,
      routes: routes,
    );
  }
}
