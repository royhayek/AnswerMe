import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:zapytaj/config/SizeConfig.dart';
import 'package:zapytaj/screens/other/QuestionDetail.dart';
import 'package:zapytaj/screens/Tabs.dart';
import 'package:zapytaj/widgets/DefaultButton.dart';
import 'package:flutter/material.dart';

enum SubmitType { store, update }

class QuestionPostedScreen extends StatefulWidget {
  final SubmitType type;
  final int questionId;

  const QuestionPostedScreen({Key key, this.type, this.questionId})
      : super(key: key);

  static const routeName = "question_posted_screen";

  @override
  _QuestionPostedScreenState createState() => _QuestionPostedScreenState();
}

class _QuestionPostedScreenState extends State<QuestionPostedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(elevation: 0),
      body: _body(),
    );
  }

  _body() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            FluentIcons.checkmark_circle_20_regular,
            size: SizeConfig.blockSizeHorizontal * 40,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(height: SizeConfig.blockSizeVertical * 2),
          Text(
            widget.type == SubmitType.store
                ? 'Question Added'
                : 'Question Updated',
            style: TextStyle(
              fontSize: SizeConfig.safeBlockHorizontal * 4.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: SizeConfig.blockSizeVertical),
          Text(
            widget.type == SubmitType.store
                ? 'Your question was added successfully!'
                : 'Your question was updated successfully!',
            style: TextStyle(
              fontSize: SizeConfig.safeBlockHorizontal * 3.5,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: SizeConfig.blockSizeVertical * 4),
          Padding(
            padding: EdgeInsets.only(
              left: SizeConfig.blockSizeHorizontal * 35,
              right: SizeConfig.blockSizeHorizontal * 35,
              top: SizeConfig.blockSizeVertical * 10,
            ),
            child: DefaultButton(
              text: 'Alright!',
              onPressed: () {
                if (widget.type == SubmitType.store) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    TabsScreen.routeName,
                    (Route<dynamic> route) => false,
                  );
                } else {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => QuestionDetailScreen(
                        questionId: widget.questionId,
                      ),
                    ),
                  );
                }
              },
              hasPadding: true,
            ),
          )
        ],
      ),
    );
  }
}
