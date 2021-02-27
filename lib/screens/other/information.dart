import 'package:provider/provider.dart';
import 'package:zapytaj/config/size_config.dart';
import 'package:zapytaj/models/badge.dart';
import 'package:zapytaj/models/point.dart';
import 'package:zapytaj/providers/app_provider.dart';
import 'package:zapytaj/services/api_repository.dart';
import 'package:zapytaj/utils/utils.dart';
import 'package:zapytaj/widgets/appbar_leading_button.dart';
import 'package:zapytaj/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';

class InformationScreen extends StatefulWidget {
  static const routeName = "information_screen";

  final String title;

  const InformationScreen({Key key, this.title}) : super(key: key);

  @override
  _InformationScreenState createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _messageController = TextEditingController();

  List<Point> _points = [];
  List<Badge> _badges = [];

  bool _isLoading = true;

  _sendMessage() async {
    if (_formKey.currentState.validate()) {
      await ApiRepository.sendMessage(
        context,
        name: _nameController.text,
        email: _emailController.text,
        message: _messageController.text,
      ).then((value) => _clearFields());
    }
  }

  _clearFields() {
    _nameController.clear();
    _emailController.clear();
    _messageController.clear();
  }

  @override
  void initState() {
    super.initState();
    if (widget.title == 'Badges & Points') {
      _getPoints();
      _getBadges();
    }
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
      leading: AppBarLeadingButton(),
      title: Text(widget.title, style: TextStyle(color: Colors.black)),
      centerTitle: true,
    );
  }

  _body(BuildContext context) {
    AppProvider appProvider = Provider.of(context, listen: false);
    switch (widget.title) {
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
      case 'Badges & Points':
        return _buildBadgesAndPointsLayout();
        break;
      case 'Contact Us':
        return _buildContactUsContent(context,
            content: appProvider.settings.contactUs);
        break;
    }
  }

  _getPoints() async {
    await ApiRepository.getPoints(context).then((points) {
      setState(() {
        _points = points;
      });
    });
  }

  _getBadges() async {
    await ApiRepository.getBadges(context).then((badges) {
      setState(() {
        _badges = badges;
      });
    });

    setState(() {
      _isLoading = false;
    });
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
            child: Form(
              key: _formKey,
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
                        CustomTextField(
                          hint: 'Name',
                          controller: _nameController,
                        ),
                        SizedBox(height: SizeConfig.blockSizeVertical * 2),
                        CustomTextField(
                          hint: 'Email',
                          controller: _emailController,
                        ),
                        SizedBox(height: SizeConfig.blockSizeVertical * 2),
                        CustomTextField(
                          hint: 'Your Message',
                          maxLines: 4,
                          controller: _messageController,
                        ),
                        SizedBox(height: SizeConfig.blockSizeVertical * 4),
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal * 25,
                          height: SizeConfig.blockSizeVertical * 6.5,
                          child: RaisedButton(
                            elevation: 0,
                            onPressed: () => _sendMessage(),
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
          ),
        ],
      ),
    );
  }

  _buildBadgesAndPointsLayout() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockSizeHorizontal * 5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: SizeConfig.blockSizeVertical * 3),
                  Text(
                    'Points',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: SizeConfig.safeBlockHorizontal * 9,
                    ),
                  ),
                  SizedBox(height: SizeConfig.blockSizeVertical),
                  Text(
                    'Besides gaining reputation with your questions and answers, you receive points for being especially helpful. Points appears on your profile page, questions & answers.',
                    style: TextStyle(
                      fontSize: SizeConfig.safeBlockHorizontal * 3.4,
                      height: SizeConfig.blockSizeVertical * 0.2,
                    ),
                  ),
                  SizedBox(height: SizeConfig.blockSizeVertical * 2),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _points.length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (ctx, i) => _pointListItem(_points[i]),
                  ),
                  SizedBox(height: SizeConfig.blockSizeVertical * 2),
                  Text(
                    'Badges',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: SizeConfig.safeBlockHorizontal * 9,
                    ),
                  ),
                  SizedBox(height: SizeConfig.blockSizeVertical),
                  Text(
                    'Besides gaining reputation with your questions and answers, you receive badges for being especially helpful. Badges appears on your profile page, questions & answers.',
                    style: TextStyle(
                      fontSize: SizeConfig.safeBlockHorizontal * 3.4,
                      height: SizeConfig.blockSizeVertical * 0.2,
                    ),
                  ),
                  SizedBox(height: SizeConfig.blockSizeVertical * 2),
                  ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _badges.length,
                      itemBuilder: (ctx, i) => _badgeListItem(_badges[i])),
                  SizedBox(height: SizeConfig.blockSizeVertical * 2),
                ],
              ),
            ),
          );
  }

  _pointListItem(Point point) {
    return Container(
      height: SizeConfig.blockSizeVertical * 6.5,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.grey.shade200),
      ),
      margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal * 2,
              vertical: SizeConfig.blockSizeHorizontal * 2.7,
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                Text(
                  point.points.toString(),
                  style: TextStyle(
                    fontSize: SizeConfig.safeBlockHorizontal * 5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  ' Points',
                  style: TextStyle(
                    fontSize: SizeConfig.safeBlockHorizontal * 3.3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: SizeConfig.blockSizeVertical * 6.5,
            color: Colors.grey.shade200,
          ),
          Expanded(
              child: Padding(
            padding: EdgeInsets.only(
              left: SizeConfig.blockSizeHorizontal * 1.5,
            ),
            child: Text(
              point.description,
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 3.4,
              ),
            ),
          )),
        ],
      ),
    );
  }

  _badgeListItem(Badge badge) {
    return Container(
      height: SizeConfig.blockSizeVertical * 17,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.grey.shade200),
      ),
      margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal * 2,
              vertical: SizeConfig.blockSizeHorizontal * 2.7,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockSizeHorizontal * 1.5,
                    vertical: SizeConfig.blockSizeVertical * 0.7,
                  ),
                  decoration: BoxDecoration(
                    color: colorConvert(badge.color),
                    borderRadius: BorderRadius.circular(
                      SizeConfig.blockSizeHorizontal * 0.7,
                    ),
                  ),
                  child: Text(
                    badge.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: SizeConfig.safeBlockHorizontal * 3.3,
                    ),
                  ),
                ),
                SizedBox(height: SizeConfig.blockSizeVertical),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      badge.to != null
                          ? '${badge.from.toString()} - ${badge.to.toString()}'
                          : badge.from.toString(),
                      style: TextStyle(
                        fontSize: SizeConfig.safeBlockHorizontal * 5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      ' Points',
                      style: TextStyle(
                        fontSize: SizeConfig.safeBlockHorizontal * 3.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: SizeConfig.blockSizeVertical * 17,
            color: Colors.grey.shade200,
          ),
          Expanded(
              child: Padding(
            padding: EdgeInsets.only(
              left: SizeConfig.blockSizeHorizontal * 1.8,
              right: SizeConfig.blockSizeHorizontal * 2,
            ),
            child: Text(
              badge.description,
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                height: SizeConfig.blockSizeVertical * 0.2,
              ),
            ),
          )),
        ],
      ),
    );
  }
}
