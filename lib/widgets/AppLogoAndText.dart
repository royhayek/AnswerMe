import 'package:flutter/material.dart';
import 'package:zapytaj/config/AppConfig.dart';
import 'package:zapytaj/config/SizeConfig.dart';

class AppLogoAndText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/app_icon.jpg',
          width: SizeConfig.blockSizeHorizontal * 24,
        ),
        Text(
          APP_NAME,
          style: TextStyle(
            fontFamily: 'Trueno',
            fontSize: SizeConfig.safeBlockHorizontal * 7,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }
}
