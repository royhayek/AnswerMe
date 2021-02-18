import 'package:flutter/material.dart';
import 'package:zapytaj/config/size_config.dart';

class CheckBoxListTile extends StatelessWidget {
  final String title;
  final bool askAuthor;
  final bool value;
  final Function onPressed;
  final bool hasPadding;
  final Widget body;
  final bool last;

  const CheckBoxListTile({
    Key key,
    this.title,
    this.askAuthor = false,
    this.hasPadding = true,
    this.value,
    this.onPressed,
    this.body,
    this.last = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!askAuthor) {
      return Column(
        children: [
          CheckboxListTile(
            contentPadding: !hasPadding
                ? EdgeInsets.symmetric(horizontal: 0)
                : EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockSizeHorizontal * 5,
                  ),
            value: value,
            onChanged: (value) => onPressed(value),
            title: Text(
              title,
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                fontWeight: FontWeight.w400,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          body != null ? body : Container(),
          !last
              ? Divider(
                  thickness: 1,
                  color: Colors.grey.shade200,
                  height: 0,
                  indent:
                      !hasPadding ? 0 : SizeConfig.blockSizeHorizontal * 4.5,
                  endIndent:
                      !hasPadding ? 0 : SizeConfig.blockSizeHorizontal * 4.5,
                )
              : Container(),
        ],
      );
    } else
      return Container();
  }
}
