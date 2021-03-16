import 'dart:io';

import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:share/share.dart';
import 'package:toast/toast.dart';
import 'package:zapytaj/config/AppConfig.dart';
import 'package:zapytaj/config/SizeConfig.dart';
import 'package:zapytaj/models/Comment.dart';
import 'package:zapytaj/models/question.dart';
import 'package:zapytaj/providers/AppProvider.dart';
import 'package:zapytaj/providers/AuthProvider.dart';
import 'package:zapytaj/screens/other/AskQuestion.dart';
import 'package:zapytaj/services/ApiRepository.dart';
import 'package:zapytaj/utils/utils.dart';
import 'package:zapytaj/widgets/AppBarLeadingButton.dart';
import 'package:zapytaj/widgets/CheckboxListTile.dart';
import 'package:zapytaj/widgets/CustomTextField.dart';
import 'package:zapytaj/widgets/DefaultButton.dart';
import 'package:zapytaj/widgets/FeaturedImagePicker.dart';
import 'package:zapytaj/widgets/QuestionAnswerListItem.dart';
import 'package:zapytaj/widgets/QuestionDetailItem.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class QuestionDetailScreen extends StatefulWidget {
  final int questionId;
  final bool answerBtnEnabled;

  const QuestionDetailScreen(
      {Key key, this.questionId, this.answerBtnEnabled = false})
      : super(key: key);

  @override
  _QuestionDetailScreenState createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  TextEditingController _answerController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _answerKey = new GlobalKey();
  AutoScrollController _controller;
  AuthProvider _authProvider;
  AppProvider _appProvider;
  bool _answerBtnEnabled = false;
  bool _isAnonymous = false;
  bool _agreeOnTerms = false;
  bool _isLoading = true;
  final _picker = ImagePicker();
  File _featuredImage;
  Question _question;
  final scrollDirection = Axis.vertical;

  @override
  void initState() {
    super.initState();
    _controller = AutoScrollController(
      viewportBoundaryGetter: () =>
          Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: scrollDirection,
    );

    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _appProvider = Provider.of<AppProvider>(context, listen: false);

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
      widget.questionId,
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

  _replyToAnswer(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      //   // _controller.animateTo(
      //   // (100.0 *
      //   //     i), // 100 is the height of container and index of 6th element is 5
      //   // duration: const Duration(milliseconds: 300),
      //   // curve: Curves.easeOut);
      //   // Scrollable.of(ctx).position.ensureVisible(ctx.findRenderObject(),
      //   //     duration: const Duration(milliseconds: 600));
      //   Scrollable.ensureVisible(ctx, duration: Duration(milliseconds: 800));
      await _controller.scrollToIndex(index,
          preferPosition: AutoScrollPosition.begin);
      _controller.highlight(index);
    });
  }

  _updateQuestionViews() async {
    await ApiRepository.updateQuestionViews(
      context,
      questionId: widget.questionId,
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

  _deleteQuestion() async {
    ApiRepository.deleteQuestion(context, questionId: widget.questionId).then(
      (value) async {
        await _appProvider.clearAllQuestions();
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );
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

  _shareQuestion() {
    if (Platform.isAndroid) {
      Share.share(
        '${_question.title}\n\n${_question.content}\n\n$SHARE_TEXT\n$ANDROID_SHARE_URL',
        subject: _question.title,
      );
    } else if (Platform.isIOS) {
      Share.share(
        '${_question.title}\n\n${_question.content}\n\n$SHARE_TEXT\n$IOS_SHARE_URL',
        subject: _question.title,
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
          onPressed: () => _shareQuestion(),
        ),
        (_authProvider.user != null && _question != null) &&
                _authProvider.user.id == _question.authorId
            ? PopupMenuButton(
                icon: Icon(
                  FluentIcons.more_vertical_20_regular,
                  color: Colors.black87,
                ),
                itemBuilder: (BuildContext bc) => [
                  PopupMenuItem(child: Text("Edit"), value: 0),
                  PopupMenuItem(child: Text("Delete"), value: 1),
                ],
                onSelected: (value) {
                  print(value);
                  if (value == 0) {
                    print('edit');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) =>
                            AskQuestionScreen(questionId: _question.id),
                      ),
                    );
                  } else
                    showConfirmationDialog(
                      context,
                      text: 'Are you sure you want to delete this question?',
                      yes: () => _deleteQuestion(),
                      no: () => Navigator.pop(context),
                    );
                },
              )
            : Container(),
      ],
    );
  }

  _body() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              children: [
                QuestionDetailItem(
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
                            scrollDirection: scrollDirection,
                            physics: NeverScrollableScrollPhysics(),
                            controller: _controller,
                            shrinkWrap: true,
                            itemBuilder: (context, i) => AutoScrollTag(
                              key: ValueKey(i),
                              controller: _controller,
                              index: i,
                              child: QuestionAnswerListItem(
                                key: ValueKey(i),
                                answer: _question.answers[i],
                                index: i,
                                question: _question,
                                questionId: _question.id,
                                getQuestion: _getQuestion,
                                bestAnswer: _question.bestAnswer,
                                replyToAnswer: _replyToAnswer,
                                controller: _controller,
                              ),
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
