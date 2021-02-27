import 'package:flutter/material.dart';
import 'package:zapytaj/config/size_config.dart';
import 'package:zapytaj/models/question.dart';
import 'package:zapytaj/services/api_repository.dart';

class PostPollImageListItem extends StatelessWidget {
  final Question question;
  final int index;
  final bool selected;
  final Function onOptionSelected;

  const PostPollImageListItem(
      {Key key,
      this.question,
      this.index,
      this.selected,
      this.onOptionSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig.blockSizeHorizontal * 60,
      height: SizeConfig.blockSizeVertical * 28,
      margin: EdgeInsets.only(
          right: SizeConfig.blockSizeHorizontal * 5,
          top: SizeConfig.blockSizeVertical * 2),
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: Colors.black54),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        children: [
          Image.network(
            '${ApiRepository.OPTION_IMAGES_PATH}${question.options[index].image}',
            height: SizeConfig.blockSizeVertical * 18,
            width: double.infinity,
            fit: BoxFit.fill,
          ),
          CheckboxListTile(
            value: selected,
            dense: true,
            onChanged: (value) => onOptionSelected(question.options[index].id),
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              question.options[index].option,
              style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 4),
            ),
          ),
        ],
      ),
    );
  }
}
