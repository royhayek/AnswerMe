import 'dart:io';

import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:toast/toast.dart';
import 'package:zapytaj/config/app_config.dart';
import 'package:zapytaj/config/size_config.dart';
import 'package:zapytaj/models/comment.dart';
import 'package:zapytaj/models/question.dart';
import 'package:zapytaj/providers/auth_provider.dart';
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

  const PostDetailScreen(
      {Key key, this.question, this.answerBtnEnabled = false})
      : super(key: key);

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  TextEditingController _answerController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _answerKey = new GlobalKey();
  final _controller = ScrollController();
  AuthProvider _authProvider;
  bool _answerBtnEnabled = false;
  bool _isAnonymous = false;
  bool _agreeOnTerms = false;
  bool _isLoading = true;
  final _picker = ImagePicker();
  File _featuredImage;
  Question _question;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _getQuestion();

    _updateQuestionViews();

    // setState(() {
    _answerBtnEnabled = widget.answerBtnEnabled;
    // });
  }

  _getQuestion() async {
    setState(() {
      _isLoading = true;
    });
    await ApiRepository.getQuestion(
      context,
      widget.question.id,
      _authProvider.user != null ? _authProvider.user.id : 0,
    ).then((question) {
      if (mounted)
        setState(() {
          _question = question;
          _isLoading = false;
        });
    });
  }

  _answerQuestion() {
    setState(() {
      _answerBtnEnabled = !_answerBtnEnabled;
    });
    if (_answerBtnEnabled)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Scrollable.ensureVisible(
          _answerKey.currentContext,
          duration: const Duration(milliseconds: 800),
        );
      });
  }

  _updateQuestionViews() async {
    await ApiRepository.updateQuestionViews(
      context,
      questionId: widget.question.id,
    );
  }

  _addAnswer() async {
    if (_formKey.currentState.validate()) {
      if (!_agreeOnTerms) {
        Toast.show('Please check terms and privacy policy', context);
        return;
      }

      String answer = _answerController.text;

      String _imageName;
      if (_featuredImage != null)
        _imageName = _featuredImage.path.split('/').last;

      Comment _comment = new Comment();
      _comment.authorId = _isAnonymous ? 0 : _authProvider.user.id;
      _comment.questionId = _question.id;
      _comment.content = answer;
      _comment.type = 'Answer';

      await ApiRepository.addComment(
        context,
        _comment,
        _featuredImage,
        _imageName,
      );

      setState(() {
        _answerBtnEnabled = false;
      });
      await _getQuestion();
    }
  }

  Future getImage() async {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _featuredImage = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  _sharePost() {
    if (Platform.isAndroid) {
      Share.share(
        '${widget.question.title}\n\n${widget.question.content}\n\n$SHARE_TEXT\n$ANDROID_SHARE_URL',
        subject: widget.question.title,
      );
    } else if (Platform.isIOS) {
      Share.share(
        '${widget.question.title}\n\n${widget.question.content}\n\n$SHARE_TEXT\n$IOS_SHARE_URL',
        subject: widget.question.title,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_answerBtnEnabled)
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Scrollable.ensureVisible(
          _answerKey.currentContext,
          duration: const Duration(milliseconds: 800),
        );
      });

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
          onPressed: () => _sharePost(),
        )
      ],
    );
  }

  _body() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              children: [
                PostDetailItem(
                  question: _question,
                  answerQuestion: _answerQuestion,
                  answerBtnEnabled: _answerBtnEnabled,
                ),
                _answerBtnEnabled ? _showAnswerLayout(context) : Container(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAnswersNumber(),
                    _question.answers.isNotEmpty
                        ? ListView.builder(
                            itemCount: _question.answers.length,
                            physics: NeverScrollableScrollPhysics(),
                            controller: _controller,
                            shrinkWrap: true,
                            itemBuilder: (context, i) => PostAnswerListItem(
                              answer: _question.answers[i],
                              question: _question,
                              questionId: _question.id,
                              getQuestion: _getQuestion,
                              bestAnswer: _question.bestAnswer,
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
    if (_question.answersCount != 0) {
      return Container(
        width: double.infinity,
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockSizeHorizontal * 5,
            vertical: SizeConfig.blockSizeVertical * 2,
          ),
          child: Text(
            _question.answersCount == 1
                ? '1 Answer'
                : '${_question.answersCount} Answers',
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
      key: _answerKey,
      margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 0.8),
      color: Colors.white,
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockSizeHorizontal * 5,
            vertical: SizeConfig.blockSizeVertical * 2,
          ),
          child: Column(
            children: [
              _buildNameAndCancelButton(context),
              FeaturedImagePicker(
                hasPadding: false,
                getImage: getImage,
                featuredImage: _featuredImage,
              ),
              _buildAnswerTextField(),
              _buildCheckBoxes(),
              SizedBox(height: SizeConfig.blockSizeVertical * 2),
              _buildPostButton(context),
              SizedBox(height: SizeConfig.blockSizeVertical),
            ],
          ),
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
        CustomTextField(
          hint: 'Answer',
          maxLines: 3,
          controller: _answerController,
        ),
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
          value: _isAnonymous,
          onPressed: (value) {
            setState(() {
              _isAnonymous = value;
            });
          },
        ),
        CheckBoxListTile(
          last: true,
          hasPadding: false,
          title:
              'By answering this question, you agreed to the Terms of Service and Privacy Policy *',
          value: _agreeOnTerms,
          onPressed: (value) {
            setState(() {
              _agreeOnTerms = value;
            });
          },
        ),
      ],
    );
  }

  _buildPostButton(BuildContext context) {
    return DefaultButton(
      text: 'Submit',
      onPressed: () => _addAnswer(),
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
