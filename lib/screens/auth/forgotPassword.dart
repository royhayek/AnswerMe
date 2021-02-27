import 'package:zapytaj/services/api_repository.dart';
import 'package:zapytaj/widgets/appbar_leading_button.dart';
import 'package:zapytaj/widgets/custom_text_field.dart';
import 'package:zapytaj/widgets/default_button.dart';
import 'package:flutter/material.dart';

import '../../config/size_config.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const routeName = 'forgot_password_screen';
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _emailController = TextEditingController();

  _resetPassword() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState.validate()) {
      await ApiRepository.forgotPassword(context, _emailController.text);
    }
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
          SizedBox(height: SizeConfig.blockSizeVertical * 20),
          _buildAppLogo(),
          SizedBox(height: SizeConfig.blockSizeVertical * 3),
          _buildTitleAndSubtitle(),
          _buildInformationFields(),
          SizedBox(height: SizeConfig.blockSizeVertical * 4),
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

  _buildTitleAndSubtitle() {
    return Column(
      children: [
        Text(
          'Forgot your Password?',
          style: TextStyle(
            fontSize: SizeConfig.safeBlockHorizontal * 3.2,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: SizeConfig.blockSizeVertical * 2.5),
        Text(
          'Enter the email address associated with your account',
          style: TextStyle(
            fontSize: SizeConfig.safeBlockHorizontal * 3.2,
            color: Colors.black54,
          ),
        )
      ],
    );
  }

  _buildInformationFields() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: Form(
        key: _formKey,
        child: CustomTextField(label: 'Email', controller: _emailController),
      ),
    );
  }

  _buildRegisterButton() {
    return DefaultButton(text: 'Reset Password', onPressed: _resetPassword);
  }
}
