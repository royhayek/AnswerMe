import 'package:zapytaj/config/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:zapytaj/models/Notification.dart' as n;
import 'package:zapytaj/screens/other/UserProfile.dart';
import 'package:zapytaj/screens/other/QuestionDetail.dart';
import 'package:zapytaj/services/ApiRepository.dart';
import 'package:zapytaj/utils/utils.dart';

class NotificationListItem extends StatelessWidget {
  final n.Notification notification;
  final Function deleteNotification;

  const NotificationListItem(
      {Key key, this.notification, this.deleteNotification})
      : super(key: key);

  _navigateToRequiredScreen(BuildContext context) {
    if (notification.questionId != null)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) =>
              QuestionDetailScreen(questionId: notification.questionId),
        ),
      );
    else if (notification.authorId != null)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => UserProfile(authorId: notification.authorId),
        ),
      );
  }

  _deleteNotification(BuildContext context) async {
    await deleteNotification(notification);
    ApiRepository.deleteUserNotification(context, id: notification.id);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical),
      child: Column(
        children: [
          InkWell(
            onTap: () => _navigateToRequiredScreen(context),
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
                      SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
                      _buildNotificationDate(),
                      SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
                      // Divider(
                      //   thickness: 1,
                      //   color: Colors.grey.shade200,
                      //   endIndent: SizeConfig.blockSizeHorizontal * 9,
                      // ),
                    ],
                  ),
                ),
                _buildDismissButton(context),
              ],
            ),
          ),
          Divider(
            thickness: 1,
            color: Colors.grey.shade200,
            indent: SizeConfig.blockSizeHorizontal * 15,
            endIndent: SizeConfig.blockSizeHorizontal * 15,
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
            notification.message,
            style: TextStyle(
              color: Colors.black.withOpacity(0.75),
              fontSize: SizeConfig.safeBlockHorizontal * 4,
            ),
          ),
        ),
      ],
    );
  }

  _buildNotificationDate() {
    return Container(
      child: Text(
        '${formatDate(notification.createdAt)} at ${formatTime(notification.createdAt)}',
//        'January 20, 2021 at 2:52 pm',
        style: TextStyle(
          fontSize: SizeConfig.safeBlockHorizontal * 3.4,
          color: Colors.black54,
        ),
      ),
    );
  }

  _buildDismissButton(BuildContext context) {
    return SizedBox(
      width: SizeConfig.blockSizeHorizontal * 15,
      height: SizeConfig.blockSizeVertical * 4,
      child: TextButton(
        style: TextButton.styleFrom(padding: EdgeInsets.only(left: 5)),
        onPressed: () => _deleteNotification(context),
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
