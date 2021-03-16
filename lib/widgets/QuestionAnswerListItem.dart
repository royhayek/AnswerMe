import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:toast/toast.dart';
import 'package:zapytaj/models/Comment.dart';
import 'package:zapytaj/config/SizeConfig.dart';
import 'package:zapytaj/models/question.dart';
import 'package:zapytaj/providers/AuthProvider.dart';
import 'package:zapytaj/services/ApiRepository.dart';
import 'package:zapytaj/utils/utils.dart';
import 'package:zapytaj/widgets/ReportButton.dart';
import 'package:zapytaj/widgets/UserInfoTile.dart';
import 'package:zapytaj/widgets/VoteButtons.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'CustomTextField.dart';

enum AnswerType { answer, reply }

class QuestionAnswerListItem extends StatefulWidget {
  final Function replyOnPressed;
  final Function cancelOnPressed;
  final Function getQuestion;
  final Comment answer;
  final Question question;
  final int bestAnswer;
  final int questionId;
  final bool hasActions;
  final bool last;
  final AnswerType type;
  final GlobalKey globalKey;
  final int index;
  final Function replyToAnswer;
  final ScrollController controller;

  const QuestionAnswerListItem({
    Key key,
    this.replyOnPressed,
    this.cancelOnPressed,
    this.getQuestion,
    this.answer,
    this.index,
    this.bestAnswer,
    this.questionId,
    this.question,
    this.hasActions = true,
    this.last = false,
    this.type = AnswerType.answer,
    this.globalKey,
    this.controller,
    this.replyToAnswer,
  }) : super(key: key);

  @override
  _QuestionAnswerListItemState createState() => _QuestionAnswerListItemState();
}

class _QuestionAnswerListItemState extends State<QuestionAnswerListItem> {
  final FocusNode _focusNode = FocusNode();
  TextEditingController _replyController = TextEditingController();
  AutoScrollController _controller;
  AuthProvider _authProvider;

  final _formKey = GlobalKey<FormState>();
  final replykey = new GlobalKey();
  // List<GlobalKey<FormState>> _formKeys = [GlobalKey<FormState>()];
  bool _reply = false;

  _replyToAnswer() async {
    AuthProvider _authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    if (_formKey.currentState.validate()) {
      String reply = _replyController.text;

      Comment _comment = new Comment();
      _comment.authorId =
          _authProvider.user != null ? _authProvider.user.id : 0;
      _comment.answerId = widget.answer.id;
      _comment.questionId = widget.questionId;
      _comment.content = reply;
      _comment.type = 'Reply';

      await ApiRepository.addComment(
        context,
        _comment,
        null,
        null,
      );

      setState(() {
        _reply = false;
      });
      await widget.getQuestion();
    }
  }

  _scrollToReplyWidget(int index) {
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    return ListView(
      controller: _controller,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        Form(
          key: _formKey,
          child: Container(
            padding: EdgeInsets.only(
              bottom:
                  widget.hasActions ? SizeConfig.blockSizeVertical * 1.5 : 0,
            ),
            margin: EdgeInsets.only(
                bottom: widget.last ? 0 : SizeConfig.blockSizeVertical * 0.8),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height:
                      widget.hasActions ? SizeConfig.blockSizeVertical * 2 : 0,
                ),
                _buildAuthorInfoAndReportButton(),
                SizedBox(height: SizeConfig.blockSizeVertical * 2),
                _buildFeaturedImage(context),
                _buildDescription(context),
                SizedBox(
                  height: widget.hasActions
                      ? SizeConfig.blockSizeVertical * 1.3
                      : widget.last
                          ? SizeConfig.blockSizeVertical * 2
                          : SizeConfig.blockSizeVertical * 4,
                ),
                widget.last
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.only(
                          left: widget.hasActions
                              ? 0
                              : SizeConfig.blockSizeHorizontal * 5,
                        ),
                        child:
                            Divider(thickness: 1, color: Colors.grey.shade200),
                      ),
                SizedBox(
                  height: widget.last ? 0 : SizeConfig.blockSizeVertical * 0.2,
                ),
                widget.hasActions ? _buildActionsRow(context) : Container(),
                SizedBox(
                  height: widget.last ? 0 : SizeConfig.blockSizeVertical * 2,
                ),
                _buildAnswerReplies(context),
              ],
            ),
          ),
        ),
        _reply ? _showReplyLayout(context) : Container(),
      ],
    );
  }

  _buildAuthorInfoAndReportButton() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: Row(
        children: [
          Expanded(
            child: UserInfoTile(
              type: Type.answerer,
              author: widget.answer.author,
              answeredOn: widget.answer.date,
              bestAnswer: widget.bestAnswer,
              answerId: widget.answer.id,
              answerType: widget.type,
              question: widget.question,
              getQuestion: widget.getQuestion,
            ),
          ),
          ReportButton(
            questionId: widget.questionId,
            answerId: widget.answer.id,
          )
        ],
      ),
    );
  }

  _buildFeaturedImage(BuildContext context) {
    return widget.answer.featuredImage != null
        ? GestureDetector(
            onTap: () => showImagePreviewDialog(
              context,
              widget.answer.featuredImage,
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: SizeConfig.blockSizeVertical * 30,
                  child: Image.network(
                    '${ApiRepository.FEATURED_IMAGES_PATH}${widget.answer.featuredImage}',
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: SizeConfig.blockSizeVertical),
              ],
            ),
          )
        : Container();
  }

  _buildDescription(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
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
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          VoteButtons(
            commentId: widget.answer.id,
            votes: widget.answer.votes,
            type: VoteType.comment,
          ),
          Spacer(),
          SizedBox(
            width: SizeConfig.blockSizeHorizontal * 18,
            height: SizeConfig.blockSizeVertical * 6,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                primary: Colors.grey.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              onPressed: () {
                if (_authProvider.user != null &&
                    _authProvider.user.id != null) {
                  setState(() {
                    _reply = !_reply;
                  });
                  if (_reply) _scrollToReplyWidget(widget.index);
                } else {
                  Toast.show(
                    'You have to login to reply to answers',
                    context,
                    duration: 2,
                  );
                }
              },
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
      ),
    );
  }

  _showReplyLayout(BuildContext context) {
    return AutoScrollTag(
      key: ValueKey(widget.index),
      controller: widget.controller,
      index: widget.index,
      child: Container(
        key: widget.globalKey,
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
              CustomTextField(
                label: 'Reply',
                controller: _replyController,
                focusNode: _focusNode,
              ),
              SizedBox(height: SizeConfig.blockSizeVertical * 4),
              _buildPostReplyButton(context),
            ],
          ),
        ),
      ),
      highlightColor: Colors.black.withOpacity(0.1),
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

  _buildPostReplyButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(bottom: SizeConfig.blockSizeHorizontal * 5),
        child: SizedBox(
          height: SizeConfig.blockSizeVertical * 6,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              primary: Theme.of(context).primaryColor,
            ),
            onPressed: () => _replyToAnswer(),
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

  _buildAnswerReplies(BuildContext context) {
    return widget.answer.replies != null
        ? ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.answer.replies.length,
            itemBuilder: (ctx, i) => Padding(
              padding: EdgeInsets.only(
                left: SizeConfig.blockSizeHorizontal * 5,
              ),
              child: Column(
                children: [
                  QuestionAnswerListItem(
                    answer: widget.answer.replies[i],
                    questionId: widget.questionId,
                    hasActions: false,
                    last: i == widget.answer.replies.length - 1 ? true : false,
                    type: AnswerType.reply,
                  ),
                ],
              ),
            ),
          )
        : Container();
  }
}
