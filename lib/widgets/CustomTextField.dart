import 'package:flutter/material.dart';

import '../config/SizeConfig.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final int maxLines;
  final double labelSize;
  final bool obscure;
  final TextEditingController controller;
  final Function onChanged;
  final FocusNode focusNode;

  const CustomTextField({
    Key key,
    this.label = '',
    this.hint,
    this.controller,
    this.maxLines,
    this.labelSize,
    this.obscure = false,
    this.onChanged,
    this.focusNode,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _showCursor = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.label != ''
              ? Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: SizeConfig.safeBlockHorizontal * 3.2,
                    color: Colors.black54,
                  ),
                )
              : Container(),
          SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
          Focus(
            onFocusChange: (focus) => setState(() => _showCursor = focus),
            child: TextFormField(
              focusNode: widget.focusNode,
              obscureText: widget.obscure,
              showCursor: widget.focusNode != null
                  ? widget.focusNode.hasFocus
                  : _showCursor,
              controller: widget.controller,
              maxLines: widget.maxLines != null ? widget.maxLines : 1,
              onChanged: widget.onChanged != null
                  ? (value) => widget.onChanged(value)
                  : (value) => null,
              decoration: InputDecoration(
                // labelText: label,
                hintText: widget.hint,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                fillColor: Colors.grey.shade100,
                filled: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockSizeHorizontal * 2,
                  vertical: SizeConfig.blockSizeVertical * 1.5,
                ),
                alignLabelWithHint: false,
                isDense: true,
                labelStyle: TextStyle(
                  fontSize: widget.labelSize != null
                      ? widget.labelSize
                      : SizeConfig.safeBlockHorizontal * 5.2,
                  color: Colors.black54,
                ),
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: SizeConfig.safeBlockHorizontal * 4,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(5),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(5),
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return '${widget.hint != null ? widget.hint : widget.label} must not be empty';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
