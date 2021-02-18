import 'package:provider/provider.dart';
import 'package:zapytaj/models/category.dart';
import 'package:zapytaj/config/size_config.dart';
import 'package:zapytaj/providers/app_provider.dart';
import 'package:zapytaj/providers/auth_provider.dart';
import 'package:zapytaj/screens/other/categoryQuestions.dart';
import 'package:flutter/material.dart';
import 'package:zapytaj/services/api_repository.dart';

class CategoriesListItem extends StatefulWidget {
  final Category category;
  final Function getCategories;

  const CategoriesListItem({Key key, this.category, this.getCategories})
      : super(key: key);

  @override
  _CategoriesListItemState createState() => _CategoriesListItemState();
}

class _CategoriesListItemState extends State<CategoriesListItem> {
  AuthProvider auth;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    auth = Provider.of<AuthProvider>(context, listen: false);

    if (auth.user != null)
      isFollowing = widget.category.followers.any(
        (follower) => follower.userId == auth.user.id,
      );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => CategoryQuestionsScreen(category: widget.category),
        ),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: SizeConfig.blockSizeVertical * 1.2,
        ),
        padding: EdgeInsets.only(
          left: SizeConfig.blockSizeHorizontal * 3,
          top: SizeConfig.blockSizeVertical * 2,
        ),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.category.name,
              style: TextStyle(color: Colors.black87),
            ),
            SizedBox(height: SizeConfig.blockSizeVertical * 1.4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                overlappedUserImages(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.category.followers.length.toString(),
                      style: TextStyle(
                        fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      'Followers',
                      style: TextStyle(
                        fontSize: SizeConfig.safeBlockHorizontal * 3.6,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                )
              ],
            ),
            Consumer<AuthProvider>(builder: (context, auth, _) {
              if (auth.user == null || auth.user.username == null) {
                return Container();
              } else {
                return Column(
                  children: [
                    SizedBox(height: SizeConfig.blockSizeVertical * 2.5),
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal * 20,
                      height: SizeConfig.blockSizeVertical * 4.5,
                      child: FlatButton(
                        color:
                            !isFollowing ? Colors.blueGrey : Colors.transparent,
                        onPressed: () async {
                          isFollowing = !isFollowing;
                          await ApiRepository.followCategory(
                            context,
                            auth.user.id,
                            widget.category.id,
                          );

                          await Provider.of<AppProvider>(context, listen: false)
                              .getCategories(context);
                        },
                        shape: !isFollowing
                            ? RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2),
                              )
                            : RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: Colors.blueGrey,
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                        padding: EdgeInsets.symmetric(horizontal: 0),
                        child: !isFollowing
                            ? Text(
                                'Follow',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              )
                            : Text(
                                'Unfollow',
                                style: TextStyle(
                                    color: Colors.blueGrey, fontSize: 12),
                              ),
                      ),
                    ),
                  ],
                );
              }
            }),
            SizedBox(height: SizeConfig.blockSizeVertical * 1.5),
          ],
        ),
      ),
    );
  }

  Widget overlappedUserImages() {
    final overlap = 15.0;

    List<Widget> items = [];
    widget.category.followers.forEach((follower) {
      items.add(_userIconCircleAvatar());
    });

    List<Widget> stackLayers = List<Widget>.generate(items.length, (index) {
      return Padding(
        padding: EdgeInsets.fromLTRB(index.toDouble() * overlap, 0, 0, 0),
        child: items[index],
      );
    });

    return widget.category.followers.length != 0
        ? Row(
            children: [
              Stack(children: stackLayers),
              SizedBox(width: SizeConfig.blockSizeHorizontal * 2),
            ],
          )
        : Row();
  }

  Widget _userIconCircleAvatar() {
    return CircleAvatar(
      child: CircleAvatar(
        backgroundImage: AssetImage('assets/images/user_icon.png'),
        backgroundColor: Colors.white,
        maxRadius: SizeConfig.blockSizeHorizontal * 4,
      ),
      maxRadius: SizeConfig.blockSizeHorizontal * 4.5,
      backgroundColor: Colors.white,
    );
  }
}
