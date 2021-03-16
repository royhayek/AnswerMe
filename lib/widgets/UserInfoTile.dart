import 'package:provider/provider.dart';
import 'package:zapytaj/config/SizeConfig.dart';
import 'package:zapytaj/models/question.dart';
import 'package:zapytaj/models/user.dart';
import 'package:zapytaj/providers/AuthProvider.dart';
import 'package:zapytaj/screens/other/UserProfile.dart';
import 'package:zapytaj/services/ApiRepository.dart';
import 'package:zapytaj/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:zapytaj/widgets/QuestionAnswerListItem.dart';

enum Type { author, answerer }

class UserInfoTile extends StatelessWidget {
  final Type type;
  final User author;
  final int votes;
  final String answeredOn;
  final int bestAnswer;
  final int answerId;
  final AnswerType answerType;
  final Question question;
  final Function getQuestion;

  const UserInfoTile({
    Key key,
    this.type,
    this.author,
    this.votes,
    this.answeredOn,
    this.bestAnswer,
    this.answerId,
    this.question,
    this.answerType,
    this.getQuestion,
  }) : super(key: key);

  _navigateToAuthorProfile(BuildContext context) {
    if (author.id != 0)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (ctx) => UserProfile(authorId: author.id)),
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
              SizedBox(height: SizeConfig.blockSizeVertical * 1),
              _buildUserRoleAndState(context),
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

  _buildUserRoleAndState(BuildContext context) {
    return author.badge != null
        ? Row(
            children: [
              Container(
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
              ),
              SizedBox(width: SizeConfig.blockSizeHorizontal * 2),
              Consumer<AuthProvider>(
                builder: (context, auth, _) => type == Type.answerer &&
                        answerType == AnswerType.answer &&
                        auth.user != null &&
                        auth.user.id == question.authorId
                    ? bestAnswer == null
                        ? _buildBestAnswerButton(
                            name: 'Set as Best Answer',
                            backgroundColor: Theme.of(context).primaryColor,
                            textColor: Colors.white,
                            border: Border(),
                            onPressed: () async =>
                                await ApiRepository.setAsBestAnswer(
                              context,
                              questionId: question.id,
                              answerId: answerId,
                            ).then((value) => getQuestion()),
                          )
                        : bestAnswer != null && bestAnswer == answerId
                            ? _buildBestAnswerButton(
                                name: 'Best Answer',
                                backgroundColor: Colors.transparent,
                                textColor: Theme.of(context).primaryColor,
                                border: Border.all(
                                  width: 1,
                                  color: Theme.of(context).primaryColor,
                                ),
                                onPressed: () => null,
                              )
                            : Container()
                    : Container(),
              )
            ],
          )
        : Container();
  }

  _buildBestAnswerButton({
    String name,
    Color backgroundColor,
    Color textColor,
    BoxBorder border,
    Function onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 2.4,
          vertical: SizeConfig.blockSizeVertical * 0.9,
        ),
        decoration: BoxDecoration(color: backgroundColor, border: border),
        child: Text(
          name,
          style: TextStyle(
            color: textColor,
            fontSize: SizeConfig.safeBlockHorizontal * 3.3,
          ),
        ),
      ),
    );
  }
}
