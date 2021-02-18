import 'dart:ui';

import 'package:zapytaj/config/size_config.dart';
import 'package:flutter/material.dart';

class DynamicQuestionField extends StatelessWidget {
  final int index;
  final String label;
  final Function remove;

  DynamicQuestionField({Key key, this.index, this.label, this.remove})
      : super(key: key);

  final TextEditingController controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                    controller: controller,
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
