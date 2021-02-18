import 'package:flutter/material.dart';

import '../config/size_config.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final int maxLines;
  final double labelSize;
  final bool obscure;
  final TextEditingController controller;
  final Function onChanged;

  const CustomTextField({
    Key key,
    this.label = '',
    this.hint,
    this.controller,
    this.maxLines,
    this.labelSize,
    this.obscure = false,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label != ''
              ? Text(
                  label,
                  style: TextStyle(
                    fontSize: SizeConfig.safeBlockHorizontal * 3.2,
                    color: Colors.black54,
                  ),
                )
              : Container(),
          TextFormField(
            obscureText: obscure,
            controller: controller,
            maxLines: maxLines != null ? maxLines : 1,
            onChanged: onChanged != null
                ? (value) => onChanged(value)
                : (value) => null,
            decoration: InputDecoration(
              // labelText: label,
              hintText: hint,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              fillColor: Colors.grey.shade100,
              filled: true,
              labelStyle: TextStyle(
                fontSize: labelSize != null
                    ? labelSize
                    : SizeConfig.safeBlockHorizontal * 5.2,
                color: Colors.black54,
              ),
              hintStyle: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: SizeConfig.safeBlockHorizontal * 4,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            validator: (value) {
              if (value.isEmpty) {
                return '$hint must not be empty';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
