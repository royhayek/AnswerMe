import 'package:zapytaj/config/SizeConfig.dart';
import 'package:flutter/material.dart';

class SettingsListItem extends StatelessWidget {
  final String text;
  final bool arrow;
  final Color color;
  final Function onTap;

  const SettingsListItem({
    Key key,
    this.text,
    this.arrow,
    this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(thickness: 1, color: Colors.grey.shade200, height: 0),
          SizedBox(height: SizeConfig.blockSizeVertical * 3),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal * 6,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: SizeConfig.safeBlockHorizontal * 4,
                    fontWeight: FontWeight.normal,
                    color: color != null ? color : Colors.black87,
                  ),
                ),
                arrow
                    ? Icon(
                        Icons.chevron_right,
                        size: SizeConfig.blockSizeHorizontal * 5,
                        color: color != null ? color : Colors.black87,
                      )
                    : Container()
              ],
            ),
          ),
          SizedBox(height: SizeConfig.blockSizeVertical * 3),
          Divider(thickness: 1, color: Colors.grey.shade200, height: 0),
        ],
      ),
    );
  }
}
