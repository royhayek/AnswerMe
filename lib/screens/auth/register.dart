import 'package:zapytaj/screens/other/Information.dart';
import 'package:zapytaj/services/ApiRepository.dart';
import 'package:zapytaj/utils/utils.dart';
import 'package:zapytaj/widgets/AppLogoAndText.dart';
import 'package:zapytaj/widgets/AppBarLeadingButton.dart';
import 'package:zapytaj/widgets/CustomTextField.dart';
import 'package:zapytaj/widgets/DefaultButton.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import '../../config/SizeConfig.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = 'register_screen';

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _agree = false;

  _registerUser() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState.validate()) {
      String _email = _emailController.value.text;
      String _username = _usernameController.value.text;
      String _password = _passwordController.value.text;

      if (_agree) {
        showLoadingDialog(context, 'Creating Account...');

        await ApiRepository.registerUser(context, _username, _email, _password)
            .then((user) {
          Navigator.pop(context);
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
      child: Form(
        key: _formKey,
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
            _buildWrappedText('By registering, you agreed to the', false),
            GestureDetector(
              onTap: () => _navigateToInformationScreen('Terms and Conditions'),
              child: _buildWrappedText('Terms of Service', true),
            ),
            _buildWrappedText(' and ', false),
            GestureDetector(
              onTap: () => _navigateToInformationScreen('Privacy Policy'),
              child: _buildWrappedText('Privacy Policy.*', true),
            ),
          ],
        ),
      ),
    );
  }

  _buildWrappedText(String text, bool hyperlink) {
    return Text(
      text,
      style: hyperlink
          ? TextStyle(
              fontSize: SizeConfig.safeBlockHorizontal * 3.5,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).primaryColor,
            )
          : TextStyle(
              fontSize: SizeConfig.safeBlockHorizontal * 3.5,
              fontWeight: FontWeight.w400,
              color: Colors.black.withOpacity(0.7),
            ),
    );
  }
}
