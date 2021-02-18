import 'package:provider/provider.dart';
import 'package:zapytaj/config/size_config.dart';
import 'package:zapytaj/providers/app_provider.dart';
import 'package:zapytaj/widgets/appbar_leading_button.dart';
import 'package:zapytaj/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';

class InformationScreen extends StatelessWidget {
  static const routeName = "information_screen";

  final String title;

  const InformationScreen({Key key, this.title}) : super(key: key);

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
      leading: AppBarLeadingButton(),
      title: Text(title, style: TextStyle(color: Colors.black)),
      centerTitle: true,
    );
  }

  _body(BuildContext context) {
    AppProvider appProvider = Provider.of(context, listen: false);
    switch (title) {
      case 'About Us':
        return _buildHtmlContent(
          body: _buildHtmlBody(content: appProvider.settings.aboutUs),
        );
        break;
      case 'Privacy Policy':
        return _buildHtmlContent(
            body: _buildHtmlBody(content: appProvider.settings.privacyPolicy));
        break;
      case 'FAQ':
        return _buildHtmlContent(
            body: _buildHtmlBody(content: appProvider.settings.faq));
        break;
      case 'Terms and Conditions':
        return _buildHtmlContent(
            body: _buildHtmlBody(
          content: appProvider.settings.termsAndConditions,
        ));
        break;
      case 'Contact Us':
        return _buildContactUsContent(context,
            content: appProvider.settings.contactUs);
        break;
    }
  }

  _buildHtmlContent({Widget body}) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 2,
        ),
        child: body,
      ),
    );
  }

  _buildHtmlBody({String content, Map<String, Style> style}) {
    return Html(
      data: content,
      style: style != null ? style : null,
    );
  }

  _buildContactUsContent(BuildContext context, {String content}) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: SizeConfig.blockSizeVertical * 2,
            color: Colors.grey.shade200,
          ),
          SizedBox(height: SizeConfig.blockSizeVertical * 4),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal * 2,
            ),
            child: Column(
              children: [
                _buildHtmlBody(
                  content: content,
                  style: {
                    'h2': Style(fontWeight: FontWeight.w500),
                    'p': Style(
                      color: Colors.black54,
                      fontSize: FontSize.large,
                      lineHeight: 1.6,
                    )
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockSizeHorizontal * 4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(height: SizeConfig.blockSizeVertical * 4),
                      CustomTextField(hint: 'Name'),
                      SizedBox(height: SizeConfig.blockSizeVertical * 2),
                      CustomTextField(hint: 'Email'),
                      SizedBox(height: SizeConfig.blockSizeVertical * 2),
                      CustomTextField(hint: 'Your Message', maxLines: 4),
                      SizedBox(height: SizeConfig.blockSizeVertical * 4),
                      SizedBox(
                        width: SizeConfig.blockSizeHorizontal * 25,
                        height: SizeConfig.blockSizeVertical * 6.5,
                        child: RaisedButton(
                          elevation: 0,
                          onPressed: () => null,
                          color: Theme.of(context).primaryColor,
                          child: Text(
                            'Send',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: SizeConfig.safeBlockHorizontal * 4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
