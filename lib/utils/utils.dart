import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:zapytaj/config/SizeConfig.dart';
import 'package:zapytaj/services/ApiRepository.dart';

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

String formatTime(String date) {
  String formattedDate = DateFormat('kk:mm a').format(DateTime.parse(date));
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
          body = Container(
            height: SizeConfig.blockSizeVertical * 8,
            color: Colors.white,
            width: double.infinity,
            child: Center(child: Text("No more questions")),
          );
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

showLoadingDialog(BuildContext context, String text) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        content: Container(
          width: 250.0,
          height: 100.0,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Please wait...',
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal * 6,
                  ),
                ),
                SizedBox(height: SizeConfig.blockSizeVertical * 3),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal * 4,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

showConfirmationDialog(
  BuildContext context, {
  String text,
  Function yes,
  Function no,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        content: Container(
          width: 250.0,
          height: SizeConfig.blockSizeVertical * 17,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal * 4.5,
                  ),
                ),
                SizedBox(height: SizeConfig.blockSizeVertical * 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: yes,
                      style: TextButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                      ),
                      child: Text('Yes', style: TextStyle(color: Colors.white)),
                    ),
                    TextButton(
                      onPressed: no,
                      style: TextButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                      ),
                      child: Text('No', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

showImagePreviewDialog(BuildContext context, String image) {
  showDialog(
    context: context,
    builder: (_) => Material(
      type: MaterialType.transparency,
      child: Center(
        child: GestureDetector(
          child: Center(
            child: Hero(
              tag: 'imageHero',
              child: Image.network(ApiRepository.FEATURED_IMAGES_PATH + image),
            ),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
    ),
  );
}
