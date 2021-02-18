import 'package:zapytaj/config/size_config.dart';
import 'package:flutter/material.dart';

class NotificationListItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildNotificationImage(context),
          SizedBox(width: SizeConfig.blockSizeHorizontal * 4.5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                _buildNotificationTitle(context),
                _buildNotificationDate(),
                SizedBox(height: SizeConfig.blockSizeVertical),
                Divider(
                  thickness: 1,
                  color: Colors.grey.shade200,
                  endIndent: SizeConfig.blockSizeHorizontal * 9,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildNotificationImage(BuildContext context) {
    return CircleAvatar(
      maxRadius: SizeConfig.blockSizeHorizontal * 6,
      backgroundColor: Theme.of(context).primaryColor,
      child: Icon(Icons.notifications, color: Colors.white),
    );
  }

  _buildNotificationTitle(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Text(
            'Gift of the site - 20 points.',
            style: TextStyle(
              color: Colors.black.withOpacity(0.75),
              fontSize: SizeConfig.safeBlockHorizontal * 4,
            ),
          ),
        ),
        _buildDismissButton(),
      ],
    );
  }

  _buildNotificationDate() {
    return Container(
      child: Text(
        'January 20, 2021 at 2:52 pm',
        style: TextStyle(
          fontSize: SizeConfig.safeBlockHorizontal * 3.4,
          color: Colors.black54,
        ),
      ),
    );
  }

  _buildDismissButton() {
    return SizedBox(
      width: SizeConfig.blockSizeHorizontal * 15,
      height: SizeConfig.blockSizeVertical * 4,
      child: FlatButton(
        padding: EdgeInsets.symmetric(horizontal: 0),
        onPressed: () => null,
        child: Text(
          'Dismiss',
          style: TextStyle(
            fontWeight: FontWeight.w300,
            color: Colors.black54,
            fontSize: SizeConfig.safeBlockHorizontal * 3.5,
          ),
        ),
      ),
    );
  }
}
