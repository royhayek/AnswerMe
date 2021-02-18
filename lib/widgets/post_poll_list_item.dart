import 'package:flutter/material.dart';
import 'package:zapytaj/config/size_config.dart';
import 'package:zapytaj/models/question.dart';

class PostPollListItem extends StatelessWidget {
  final Question question;
  final int index;

  const PostPollListItem({Key key, this.question, this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeConfig.blockSizeVertical * 6,
      child: CheckboxListTile(
        value: false,
        onChanged: (value) => null,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          question.options[index].option,
          style: TextStyle(
            color: Colors.black54,
            fontSize: SizeConfig.safeBlockHorizontal * 4.3,
          ),
        ),
      ),
    );
  }
}
