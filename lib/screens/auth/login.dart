import 'package:zapytaj/models/user.dart';
import 'package:zapytaj/providers/AuthProvider.dart';
import 'package:zapytaj/screens/auth/ForgotPassword.dart';
import 'package:zapytaj/screens/auth/Register.dart';
import 'package:zapytaj/config/SizeConfig.dart';
import 'package:zapytaj/screens/Tabs.dart';
import 'package:zapytaj/utils/SessionManager.dart';
import 'package:zapytaj/utils/utils.dart';
import 'package:zapytaj/widgets/AppLogoAndText.dart';
import 'package:zapytaj/widgets/CustomTextField.dart';
import 'package:zapytaj/widgets/DefaultButton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  AuthProvider authProvider;
  SessionManager prefs = SessionManager();

  _loginUser() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState.validate()) {
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      String _username = _usernameController.value.text;
      String _password = _passwordController.value.text;

      showLoadingDialog(context, 'Logging in...');
      User user = await authProvider.loginUser(context, _username, _password);
      Navigator.pop(context);

      if (user != null) _navigateToTabsScreen();
    }
  }

  _navigateToTabsScreen() {
    Navigator.pushReplacementNamed(context, TabsScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(),
      body: _body(context),
    );
  }

  _appBar() {
    return AppBar(
      elevation: 0,
      actions: [
        TextButton(
          onPressed: _navigateToTabsScreen,
          child: Text(
            'SKIP',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
        ),
      ],
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
          SizedBox(height: SizeConfig.blockSizeVertical * 4),
          _buildLoginButton(),
          SizedBox(height: SizeConfig.blockSizeVertical * 3),
          _buildForgotPasswordButton(context),
          SizedBox(height: SizeConfig.blockSizeVertical * 3),
          _buildNeedAnAccountButton(context),
        ],
      ),
    );
  }

  _buildAppLogo() {
    return SizedBox(
      width: SizeConfig.blockSizeHorizontal * 100,
      height: SizeConfig.blockSizeVertical * 16,
      child: AppLogoAndText(),
    );
  }

  _buildInformationFields() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomTextField(
              label: 'Username',
              controller: _usernameController,
            ),
            SizedBox(height: SizeConfig.blockSizeVertical * 2),
            CustomTextField(
              label: 'Password',
              obscure: true,
              controller: _passwordController,
            ),
          ],
        ),
      ),
    );
  }

  _buildLoginButton() {
    return DefaultButton(text: 'Login', onPressed: _loginUser);
  }

  _buildForgotPasswordButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, ForgotPasswordScreen.routeName),
      child: Text(
        'Forgot Password?',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  _buildNeedAnAccountButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Need an account?',
          style: TextStyle(
            fontSize: SizeConfig.safeBlockHorizontal * 4,
            color: Colors.black54,
          ),
        ),
        SizedBox(width: SizeConfig.blockSizeHorizontal * 1.6),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, RegisterScreen.routeName),
          child: Text(
            'Create an account',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: SizeConfig.safeBlockHorizontal * 4.2,
            ),
          ),
        ),
      ],
    );
  }
}
