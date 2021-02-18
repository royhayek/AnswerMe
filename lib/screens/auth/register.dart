import 'package:zapytaj/screens/other/information.dart';
import 'package:zapytaj/services/api_repository.dart';
import 'package:zapytaj/widgets/appbar_leading_button.dart';
import 'package:zapytaj/widgets/custom_text_field.dart';
import 'package:zapytaj/widgets/default_button.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import '../../config/size_config.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = 'register_screen';

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _agree = false;

  _registerUser() async {
    String _email = _emailController.value.text;
    String _username = _usernameController.value.text;
    String _password = _passwordController.value.text;

    if (_agree) {
      await ApiRepository.registerUser(context, _username, _email, _password)
          .then((user) {
        if (user != null) {
          Navigator.pop(context);
        }
      });
    } else {
      Toast.show(
        'You need to agree to the Terms of Service and Privacy Policy',
        context,
        duration: 2,
      );
    }
  }

  _navigateToInformationScreen(String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InformationScreen(title: title)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(context),
      body: _body(context),
    );
  }

  _appBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      leading: AppBarLeadingButton(),
    );
  }

  _body(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: SizeConfig.blockSizeVertical * 10),
          _buildAppLogo(),
          SizedBox(height: SizeConfig.blockSizeVertical * 3),
          _buildInformationFields(),
          SizedBox(height: SizeConfig.blockSizeVertical * 2),
          _buildCheckboxTile(),
          SizedBox(height: SizeConfig.blockSizeVertical * 3),
          _buildRegisterButton(),
        ],
      ),
    );
  }

  _buildAppLogo() {
    return SizedBox(
      width: SizeConfig.blockSizeHorizontal * 100,
      height: SizeConfig.blockSizeVertical * 16,
      child: Image.asset('assets/images/app_logo.jpg'),
    );
  }

  _buildInformationFields() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: Column(
        children: [
          CustomTextField(label: 'Email', controller: _emailController),
          CustomTextField(label: 'Username', controller: _usernameController),
          CustomTextField(
            label: 'Password',
            obscure: true,
            controller: _passwordController,
          ),
        ],
      ),
    );
  }

  _buildRegisterButton() {
    return DefaultButton(
      text: 'Register',
      onPressed: _registerUser,
    );
  }

  _buildCheckboxTile() {
    return Theme(
      data: ThemeData(unselectedWidgetColor: Colors.black54),
      child: CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        value: _agree,
        onChanged: (state) {
          setState(() {
            _agree = state;
          });
        },
        title: Wrap(
          children: [
            Text(
              'By registering, you agreed to the',
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 4,
                color: Colors.black54,
              ),
            ),
            GestureDetector(
              onTap: () => _navigateToInformationScreen('Terms and Conditions'),
              child: Text(
                'Terms of Service',
                style: TextStyle(
                  fontSize: SizeConfig.safeBlockHorizontal * 4,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            Text(
              ' and ',
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 4,
                color: Colors.black54,
              ),
            ),
            GestureDetector(
              onTap: () => _navigateToInformationScreen('Privacy Policy'),
              child: Text(
                'Privacy Policy.*',
                style: TextStyle(
                  fontSize: SizeConfig.safeBlockHorizontal * 4,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
