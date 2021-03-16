import 'dart:ui';

import 'package:zapytaj/config/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:zapytaj/models/Option.dart';

class DynamicQuestionField extends StatelessWidget {
  final int index;
  final String label;
  final Function remove;
  final Option option;

  DynamicQuestionField({
    Key key,
    this.index,
    this.label,
    this.remove,
    this.option,
  }) : super(key: key);

  final TextEditingController idController = new TextEditingController();
  final TextEditingController inputController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (option != null) {
      idController.text = option.id.toString();
      inputController.text = option.option;
    }
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
        vertical: SizeConfig.blockSizeVertical,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: SizeConfig.safeBlockHorizontal * 3,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: SizeConfig.blockSizeVertical * 0.3),
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 6,
                  child: TextField(
                    controller: inputController,
                    focusNode: FocusNode(canRequestFocus: false),
                    decoration: InputDecoration(
                      fillColor: Colors.grey.shade100,
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey.shade200,
                          width: 0.5,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: SizeConfig.blockSizeHorizontal * 4),
          InkWell(
            onTap: () => remove(index),
            child: Container(
              width: SizeConfig.blockSizeHorizontal * 8,
              height: SizeConfig.blockSizeHorizontal * 8,
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Icon(
                Icons.delete,
                color: Colors.white,
                size: SizeConfig.blockSizeHorizontal * 5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
