import 'package:zapytaj/models/comment.dart';
import 'package:zapytaj/screens/other/postDetail.dart';
import 'package:zapytaj/config/size_config.dart';
import 'package:zapytaj/widgets/report_button.dart';
import 'package:zapytaj/widgets/user_info_tile.dart';
import 'package:zapytaj/widgets/vote_buttons.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'custom_text_field.dart';

class PostAnswerListItem extends StatefulWidget {
  final Function replyOnPressed;
  final Function cancelOnPressed;
  final Comment answer;
  final int questionId;

  const PostAnswerListItem(
      {Key key,
      this.replyOnPressed,
      this.cancelOnPressed,
      this.answer,
      this.questionId})
      : super(key: key);

  @override
  _PostAnswerListItemState createState() => _PostAnswerListItemState();
}

class _PostAnswerListItemState extends State<PostAnswerListItem> {
  bool _reply = false;

  _navigateToPostDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => PostDetailScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(
            SizeConfig.blockSizeHorizontal * 6,
            0,
            SizeConfig.blockSizeHorizontal * 6,
            SizeConfig.blockSizeVertical * 1.5,
          ),
          margin: EdgeInsets.only(
            bottom: SizeConfig.blockSizeVertical * 0.8,
            // top: SizeConfig.blockSizeVertical * 0.4,
          ),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: SizeConfig.blockSizeVertical * 2),
              _buildAuthorInfoAndReportButton(),
              SizedBox(height: SizeConfig.blockSizeVertical * 2),
              _buildDescription(context),
              SizedBox(height: SizeConfig.blockSizeVertical * 1.3),
              Divider(thickness: 1, color: Colors.grey.shade200),
              SizedBox(height: SizeConfig.blockSizeVertical * 0.2),
              _buildActionsRow(context),
            ],
          ),
        ),
        _reply ? _showReplyLayout(context) : Container(),
      ],
    );
  }

  _buildAuthorInfoAndReportButton() {
    return Row(
      children: [
        Expanded(
          child: UserInfoTile(
            type: Type.answerer,
            author: widget.answer.author,
            answeredOn: widget.answer.date,
          ),
        ),
        ReportButton(questionId: widget.questionId, answerId: widget.answer.id)
      ],
    );
  }

  _buildDescription(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToPostDetail(context),
      child: Text(
        widget.answer.content,
        style: TextStyle(
          fontSize: SizeConfig.safeBlockHorizontal * 4.1,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
          height: 1.2,
        ),
      ),
    );
  }

  _buildActionsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        VoteButtons(),
        Spacer(),
        SizedBox(
          width: SizeConfig.blockSizeHorizontal * 18,
          height: SizeConfig.blockSizeVertical * 6,
          child: RaisedButton(
            elevation: 0,
            onPressed: () {
              setState(() {
                _reply = !_reply;
              });
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
            ),
            color: Colors.grey.shade200,
            child: Text(
              'Reply',
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                color: Colors.black54,
              ),
            ),
          ),
        )
      ],
    );
  }

  _showReplyLayout(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 5,
          vertical: SizeConfig.blockSizeVertical * 3,
        ),
        child: Column(
          children: [
            _buildNameAndCancelButton(context),
            CustomTextField(label: 'Reply'),
            SizedBox(height: SizeConfig.blockSizeVertical * 4),
            _buildPostButton(context),
          ],
        ),
      ),
    );
  }

  _buildNameAndCancelButton(BuildContext context) {
    return Row(
      children: [
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(math.pi),
          child: Icon(Icons.reply, color: Theme.of(context).primaryColor),
        ),
        SizedBox(width: SizeConfig.blockSizeHorizontal * 2),
        Text(
          'Reply to ',
          style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 3.5),
        ),
        RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.black),
            children: <TextSpan>[
              TextSpan(
                text: widget.answer.author.displayname,
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ),
        ),
        Spacer(),
        InkWell(
          onTap: () {
            setState(() {
              _reply = !_reply;
            });
          },
          child: Text(
            'Cancel',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  _buildPostButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(bottom: SizeConfig.blockSizeHorizontal * 5),
        child: SizedBox(
          height: SizeConfig.blockSizeVertical * 6,
          child: RaisedButton(
            elevation: 0,
            onPressed: () => null,
            color: Theme.of(context).primaryColor,
            child: Text(
              'Post Reply',
              style: TextStyle(
                color: Colors.white,
                fontSize: SizeConfig.safeBlockHorizontal * 3.7,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
