import 'package:zapytaj/config/size_config.dart';
import 'package:zapytaj/widgets/appbar_leading_button.dart';
import 'package:zapytaj/widgets/notification_list_item.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  static const routeName = "notifications_screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(),
      body: _body(),
    );
  }

  _appBar() {
    return AppBar(
      centerTitle: true,
      title: Text('Notifications', style: TextStyle(color: Colors.black)),
      leading: AppBarLeadingButton(),
    );
  }

  _body() {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        top: SizeConfig.blockSizeVertical * 3,
        bottom: SizeConfig.blockSizeVertical * 3,
        left: SizeConfig.blockSizeHorizontal * 5,
        right: SizeConfig.blockSizeHorizontal * 4,
      ),
      itemCount: 2,
      itemBuilder: (ctx, i) => NotificationListItem(),
    );
  }
}
