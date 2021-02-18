import 'package:zapytaj/config/size_config.dart';
import 'package:zapytaj/models/user.dart';
import 'package:zapytaj/screens/other/authorProfile.dart';
import 'package:zapytaj/services/api_repository.dart';
import 'package:zapytaj/utils/utils.dart';
import 'package:flutter/material.dart';

enum Type { author, answerer }

class UserInfoTile extends StatelessWidget {
  final Type type;
  final User author;
  final int votes;
  final String answeredOn;

  const UserInfoTile(
      {Key key, this.type, this.author, this.votes, this.answeredOn})
      : super(key: key);

  _navigateToAuthorProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => AuthorProfile(author: author)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        _buildUserImage(context),
        SizedBox(width: SizeConfig.blockSizeHorizontal * 2.7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              _buildUserName(context),
              SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
              _buildUserRole(),
              type == Type.answerer
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(thickness: 1, color: Colors.grey.shade200),
                        Text(
                          'Answer On $answeredOn',
                          style: TextStyle(
                            fontSize: SizeConfig.safeBlockHorizontal * 3.4,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    )
                  : Container(),
            ],
          ),
        ),
      ],
    );
  }

  _buildUserImage(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToAuthorProfile(context),
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        backgroundImage: author != null && author.avatar != null
            ? NetworkImage(
                '${ApiRepository.AVATAR_IMAGES_PATH}${author.avatar}',
              )
            : AssetImage('assets/images/user_icon.png'),
        maxRadius: SizeConfig.blockSizeHorizontal * 8,
      ),
    );
  }

  _buildUserName(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        GestureDetector(
          onTap: () => _navigateToAuthorProfile(context),
          child: Text(
            author != null ? author.displayname : 'Anonymous',
            style: TextStyle(
              color: author != null
                  ? Theme.of(context).primaryColor
                  : Colors.black,
              fontSize: SizeConfig.safeBlockHorizontal * 4.1,
              fontWeight:
                  type == Type.author ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        // SizedBox(width: SizeConfig.blockSizeVertical * 1.6),
        // CircleAvatar(
        //   child: Icon(
        //     Icons.done_sharp,
        //     color: Colors.white,
        //     size: SizeConfig.blockSizeHorizontal * 4,
        //   ),
        //   backgroundColor: Theme.of(context).primaryColor,
        //   maxRadius: SizeConfig.blockSizeHorizontal * 2.5,
        // ),
      ],
    );
  }

  _buildUserRole() {
    return author != null
        ? Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal * 2.4,
              vertical: SizeConfig.blockSizeVertical * 0.9,
            ),
            decoration: BoxDecoration(
              color: colorConvert(author.badge.color),
              borderRadius: BorderRadius.circular(
                SizeConfig.blockSizeHorizontal * 0.7,
              ),
            ),
            child: Text(
              author.badge.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: SizeConfig.safeBlockHorizontal * 3.3,
              ),
            ),
          )
        : Container();
  }
}
