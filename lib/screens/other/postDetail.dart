import 'package:zapytaj/config/size_config.dart';
import 'package:zapytaj/models/question.dart';
import 'package:zapytaj/services/api_repository.dart';
import 'package:zapytaj/widgets/appbar_leading_button.dart';
import 'package:zapytaj/widgets/checkbox_list_tile.dart';
import 'package:zapytaj/widgets/custom_text_field.dart';
import 'package:zapytaj/widgets/default_button.dart';
import 'package:zapytaj/widgets/featured_image_picker.dart';
import 'package:zapytaj/widgets/post_answer_list_item.dart';
import 'package:zapytaj/widgets/post_detail_item.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class PostDetailScreen extends StatefulWidget {
  final Question question;
  final bool answerBtnEnabled;

  const PostDetailScreen({Key key, this.question, this.answerBtnEnabled})
      : super(key: key);

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _controller = ScrollController();
  bool _answerBtnEnabled;
  bool isAnonymous = false;
  bool agreeOnTerms = false;

  @override
  void initState() {
    super.initState();
    _answerBtnEnabled = widget.answerBtnEnabled;

    _updateQuestionViews();
  }

  _answerQuestion() {
    setState(() {
      _answerBtnEnabled = !_answerBtnEnabled;
    });
  }

  _updateQuestionViews() async {
    await ApiRepository.updateQuestionViews(
      context,
      questionId: widget.question.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _body(),
    );
  }

  _appBar() {
    return AppBar(
      leading: AppBarLeadingButton(),
      actions: [
        IconButton(
          icon: Icon(FluentIcons.share_ios_20_filled, color: Colors.black87),
          onPressed: () => null,
        )
      ],
    );
  }

  _body() {
    return SingleChildScrollView(
      child: Column(
        children: [
          PostDetailItem(
            question: widget.question,
            answerQuestion: _answerQuestion,
            answerBtnEnabled: _answerBtnEnabled,
          ),
          _answerBtnEnabled ? _showAnswerLayout(context) : Container(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAnswersNumber(),
              widget.question.answers.isNotEmpty
                  ? ListView.builder(
                      itemCount: widget.question.answers.length,
                      physics: NeverScrollableScrollPhysics(),
                      controller: _controller,
                      shrinkWrap: true,
                      itemBuilder: (context, i) => PostAnswerListItem(
                        answer: widget.question.answers[i],
                        questionId: widget.question.id,
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.only(
                        top: SizeConfig.blockSizeVertical * 2,
                        bottom: SizeConfig.blockSizeVertical * 2,
                      ),
                      child: Center(child: Text('No Answers Yet')),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  _buildAnswersNumber() {
    if (widget.question.answersCount != 0) {
      return Container(
        width: double.infinity,
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockSizeHorizontal * 5,
            vertical: SizeConfig.blockSizeVertical * 2,
          ),
          child: Text(
            widget.question.answersCount == 1
                ? '1 Answer'
                : '${widget.question.answersCount} Answers',
            style: TextStyle(
              fontSize: SizeConfig.safeBlockHorizontal * 4.2,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  _showAnswerLayout(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 0.8),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 5,
          vertical: SizeConfig.blockSizeVertical * 2,
        ),
        child: Column(
          children: [
            _buildNameAndCancelButton(context),
            FeaturedImagePicker(hasPadding: false),
            _buildAnswerTextField(),
            _buildCheckBoxes(),
            SizedBox(height: SizeConfig.blockSizeVertical * 2),
            _buildPostButton(context),
            SizedBox(height: SizeConfig.blockSizeVertical),
          ],
        ),
      ),
    );
  }

  _buildNameAndCancelButton(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'LEAVE AN ANSWER',
              style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 4),
            ),
            Spacer(),
            InkWell(
              onTap: () => _answerBtnEnabled ? _answerQuestion() : null,
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).primaryColor,
                  fontSize: SizeConfig.safeBlockHorizontal * 3.7,
                ),
              ),
            )
          ],
        ),
        SizedBox(height: SizeConfig.blockSizeVertical * 3),
        Divider(thickness: 1, color: Colors.grey.shade200, height: 0),
      ],
    );
  }

  _buildAnswerTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: SizeConfig.blockSizeVertical),
        Divider(thickness: 1, color: Colors.grey.shade200, height: 0),
        SizedBox(height: SizeConfig.blockSizeVertical * 2),
        Text(
          'Answer *',
          style: TextStyle(
            fontSize: SizeConfig.safeBlockHorizontal * 4.2,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        CustomTextField(hint: 'Answer', maxLines: 3),
        SizedBox(height: SizeConfig.blockSizeVertical),
        Text(
          'Type your answer thoroughly and in details',
          style: TextStyle(
            fontSize: SizeConfig.safeBlockHorizontal * 3.2,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  _buildCheckBoxes() {
    return Column(
      children: [
        CheckBoxListTile(
          hasPadding: false,
          title: 'Answer Anonymously',
          value: isAnonymous,
          onPressed: (value) {
            setState(() {
              isAnonymous = value;
            });
          },
        ),
        CheckBoxListTile(
          last: true,
          hasPadding: false,
          title:
              'By answering this question, you agreed to the Terms of Service and Privacy Policy *',
          value: agreeOnTerms,
          onPressed: (value) {
            setState(() {
              agreeOnTerms = value;
            });
          },
        ),
      ],
    );
  }

  _buildPostButton(BuildContext context) {
    return DefaultButton(
      text: 'Submit',
      onPressed: () => null,
      hasPadding: false,
    );
  }

  // replyOnPressed() {
  //   setState(() {
  //     _replyOnPressed = !_replyOnPressed;
  //     _controller.jumpTo(_controller.position.maxScrollExtent);
  //   });
  // }

  // _cancelOnPressed() {
  //   setState(() {
  //     _replyOnPressed = !_replyOnPressed;
  //   });
  // }
}
