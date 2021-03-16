import 'package:zapytaj/config/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:zapytaj/models/user.dart';
import 'package:zapytaj/screens/other/AskQuestion.dart';
import 'package:zapytaj/screens/other/UserProfile.dart';
import 'package:zapytaj/services/ApiRepository.dart';
import 'package:zapytaj/utils/utils.dart';

class UserFollowTile extends StatelessWidget {
  final User user;

  const UserFollowTile({Key key, this.user}) : super(key: key);

  _askAQuestion(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AskQuestionScreen(
          askAuthor: true,
          authorId: user.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildUserImage(context),
          SizedBox(width: SizeConfig.blockSizeHorizontal * 4.5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                _buildUserName(context),
                SizedBox(height: SizeConfig.blockSizeVertical * 2.2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildUserRole(),
                    _buildAskButton(context),
                  ],
                ),
                SizedBox(height: SizeConfig.blockSizeVertical),
                Divider(thickness: 1, color: Colors.grey.shade200),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildUserImage(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (ctx) => UserProfile(authorId: user.id)),
      ),
      child: user.avatar == null
          ? CircleAvatar(
              backgroundImage: AssetImage('assets/images/user_icon.png'),
              maxRadius: SizeConfig.blockSizeHorizontal * 8,
            )
          : CircleAvatar(
              backgroundImage: NetworkImage(
                '${ApiRepository.AVATAR_IMAGES_PATH}${user.avatar}',
              ),
              maxRadius: SizeConfig.blockSizeHorizontal * 8,
            ),
    );
  }

  _buildUserName(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (ctx) => UserProfile(authorId: user.id)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            user.displayname,
            style: TextStyle(
              color: Colors.black,
              fontSize: SizeConfig.safeBlockHorizontal * 4.1,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  _buildUserRole() {
    return user.badge != null
        ? Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal * 2.4,
              vertical: SizeConfig.blockSizeVertical * 0.9,
            ),
            decoration: BoxDecoration(
              color: colorConvert(user.badge.color),
              borderRadius: BorderRadius.circular(
                SizeConfig.blockSizeHorizontal * 0.7,
              ),
            ),
            child: Text(
              user.badge.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: SizeConfig.safeBlockHorizontal * 3.3,
              ),
            ),
          )
        : Container();
  }

  _buildAskButton(BuildContext context) {
    return InkWell(
      onTap: () => _askAQuestion(context),
      child: Container(
        height: SizeConfig.blockSizeVertical * 3.5,
        decoration: BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: BorderRadius.circular(2),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 3,
          vertical: SizeConfig.blockSizeVertical * 0.5,
        ),
        child: Text(
          'Ask',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: SizeConfig.safeBlockHorizontal * 3.5,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
