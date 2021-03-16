// import 'package:admob_consent/admob_consent.dart';
import 'dart:async';

import 'package:admob_consent/admob_consent.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:zapytaj/config/AppTheme.dart';
import 'package:zapytaj/providers/AppProvider.dart';
import 'package:zapytaj/providers/AuthProvider.dart';
import 'package:zapytaj/screens/landing/Splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zapytaj/utils/NotificationService.dart';

import 'routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Admob.initialize();
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

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AdmobConsent _admobConsent = AdmobConsent();
  StreamSubscription<void> _subscription;

  @override
  void initState() {
    super.initState();
    NotificationService.instance.start();
    _subscription = _admobConsent.onConsentFormObtained.listen((o) {
      // Obtained consent
    });
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    _admobConsent.show(forceShow: true);
  }

  @override
  void dispose() {
    _subscription.cancel();
    _admobConsent.dispose();
    super.dispose();
  }

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
