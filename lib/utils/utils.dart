import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

Future showCustomDialogWithTitle(
  BuildContext context, {
  String title,
  Widget body,
  Function onTapCancel,
  Function onTapSubmit,
}) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: title != null ? Text(title) : Container(),
        content: SingleChildScrollView(child: body),
        actions: <Widget>[
          onTapCancel != null
              ? TextButton(
                  child: Text('Cancel'),
                  onPressed: onTapCancel,
                )
              : Container(),
          onTapSubmit != null
              ? TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: Text('Submit', style: TextStyle(color: Colors.white)),
                  onPressed: onTapSubmit,
                )
              : Container(),
        ],
      );
    },
  );
}

Future showCustomEmptyDialog(
  BuildContext context, {
  Widget body,
}) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(child: body),
      );
    },
  );
}

String formatDate(String date) {
  String formattedDate = DateFormat('MMMM d, y').format(DateTime.parse(date));
  return formattedDate;
}

Widget swipeToRefresh(context,
    {Widget child,
    refreshController,
    VoidCallback onRefresh,
    VoidCallback onLoading}) {
  return SmartRefresher(
    enablePullDown: true,
    enablePullUp: true,
    controller: refreshController,
    onRefresh: onRefresh,
    onLoading: onLoading,
    footer: CustomFooter(
      builder: (BuildContext context, LoadStatus mode) {
        Widget body;
        if (mode == LoadStatus.idle) {
          body = Text("");
        } else if (mode == LoadStatus.loading) {
          body = CupertinoActivityIndicator();
        } else if (mode == LoadStatus.failed) {
          body = Text("Load Failed! Click retry!");
        } else if (mode == LoadStatus.canLoading) {
          body = Text("release to load more");
        } else {
          body = Text("No more products");
        }
        return Container(
          height: 55.0,
          child: Center(child: body),
        );
      },
    ),
    child: child,
  );
}

Color colorConvert(String color) {
  color = color.replaceAll("#", "");
  if (color.length == 6) {
    return Color(int.parse("0xFF" + color));
  } else if (color.length == 8) {
    return Color(int.parse("0x" + color));
  }
  return Colors.black;
}
