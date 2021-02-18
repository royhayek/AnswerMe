import 'package:zapytaj/config/app_config.dart';
import 'package:zapytaj/screens/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:minimal_onboarding/minimal_onboarding.dart';

class OnBoardingScreen extends StatelessWidget {
  static const routeName = 'onboarding_screen';

  final onboardingPages = [
    OnboardingPageModel(
      'assets/images/onboarding_1.jpg',
      'Welcome',
      '$APP_NAME is a stunning profressional and flexible social questions and answers app',
    ),
    OnboardingPageModel(
      'assets/images/onboarding_2.jpg',
      'You are here',
      'Specialy designed for Online Communities, Niche Questions and Answers Websites.',
    ),
    OnboardingPageModel(
      'assets/images/onboarding_3.jpg',
      'Continue to zapytaj',
      'Marketing Websites, Developers Websites, or any kind of Social Communities',
    ),
  ];

  _navigateToLoginScreen(BuildContext context) {
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MinimalOnboarding(
        onboardingPages: onboardingPages,
        dotsDecoration: DotsDecorator(
          activeColor: Color(0xFF4E67EB),
          size: const Size.square(9.0),
          activeSize: const Size(18.0, 9.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
        onFinishButtonPressed: () => _navigateToLoginScreen(context),
        onSkipButtonPressed: () => _navigateToLoginScreen(context),
      ),
    );
  }
}
