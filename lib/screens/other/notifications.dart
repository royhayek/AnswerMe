import 'package:provider/provider.dart';
import 'package:zapytaj/config/SizeConfig.dart';
import 'package:zapytaj/models/Notification.dart' as n;
import 'package:zapytaj/providers/AuthProvider.dart';
import 'package:zapytaj/services/ApiRepository.dart';
import 'package:zapytaj/widgets/AppBarLeadingButton.dart';
import 'package:zapytaj/widgets/NotificationListItem.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  static const routeName = "notifications_screen";

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  AuthProvider _authProvider;
  bool _isLoading = true;
  List<n.Notification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _getUserNotifications();
  }

  _getUserNotifications() async {
    await ApiRepository.getUserNotifications(
      context,
      userId: _authProvider.user.id,
    ).then((notifications) {
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    });
  }

  _deleteNotification(n.Notification notification) async {
    setState(() {
      _notifications.remove(notification);
    });
    await _authProvider.getUserInfo(context, _authProvider.user.id);
  }

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
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              top: SizeConfig.blockSizeVertical * 3,
              bottom: SizeConfig.blockSizeVertical * 3,
              left: SizeConfig.blockSizeHorizontal * 5,
              right: SizeConfig.blockSizeHorizontal * 4,
            ),
            itemCount: _notifications.length,
            itemBuilder: (ctx, i) => NotificationListItem(
              notification: _notifications[i],
              deleteNotification: _deleteNotification,
            ),
          );
  }
}
