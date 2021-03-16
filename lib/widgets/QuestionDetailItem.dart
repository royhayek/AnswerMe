import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zapytaj/models/question.dart';
import 'package:zapytaj/config/SizeConfig.dart';
import 'package:zapytaj/models/ResultOption.dart';
import 'package:zapytaj/providers/AppProvider.dart';
import 'package:zapytaj/providers/AuthProvider.dart';
import 'package:zapytaj/services/ApiRepository.dart';
import 'package:zapytaj/utils/utils.dart';
import 'package:zapytaj/widgets/QuestionPollImageListItem.dart';
import 'package:zapytaj/widgets/QuestionPollListItem.dart';
import 'package:zapytaj/widgets/QuestionPollResultListItem.dart';
import 'package:zapytaj/widgets/ReportButton.dart';
import 'package:zapytaj/widgets/UserInfoTile.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:zapytaj/widgets/VoteButtons.dart';

class QuestionDetailItem extends StatefulWidget {
  final Question question;
  final Function answerQuestion;
  final bool answerBtnEnabled;
  final Function addToFav;
  final Function removeFromFav;

  const QuestionDetailItem({
    Key key,
    this.question,
    this.answerQuestion,
    this.answerBtnEnabled,
    this.addToFav,
    this.removeFromFav,
  }) : super(key: key);

  @override
  _QuestionDetailItemState createState() => _QuestionDetailItemState();
}

class _QuestionDetailItemState extends State<QuestionDetailItem> {
  int _selectedOption;
  AuthProvider _authProvider;
  bool _showResults = false;
  bool _loadingPolls = false;
  bool _isFavorite = false;
  ResultOption _resultOptions;

  _onOptionSelected(int option) {
    setState(() {
      _selectedOption = option;
    });
  }

  _submitOption() async {
    if (_selectedOption != 0) {
      await ApiRepository.submitOption(
        context,
        userId: _authProvider.user != null ? _authProvider.user.id : 0,
        questionId: widget.question.id,
        optionId: _selectedOption,
      ).then((value) => _checkIfOptionSelected());
    } else {
      Toast.show('Please select an option', context, duration: 2);
    }
  }

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (widget.question.favorite == 1)
      _isFavorite = true;
    else
      _isFavorite = false;

    if (widget.question.polled == 1) {
      _checkIfOptionSelected();
    }
  }

  _checkIfOptionSelected() async {
    setState(() {
      _loadingPolls = true;
    });
    await ApiRepository.checkIfOptionSelected(
      context,
      questionId: widget.question.id,
      userId: _authProvider.user != null ? _authProvider.user.id : 0,
    ).then((value) {
      setState(() {
        _selectedOption = value;
      });
      if (value != 0)
        _displayVoteReult();
      else
        setState(() {
          _loadingPolls = false;
        });
    });
  }

  _displayVoteReult() async {
    await ApiRepository.displayVoteResult(
      context,
      questionId: widget.question.id,
      userId: _authProvider.user != null ? _authProvider.user.id : 0,
    ).then((value) {
      setState(() {
        _resultOptions = value;
        if (_resultOptions.votesCount != 0) {
          setState(() {
            _showResults = true;
          });
        } else {
          Toast.show(
            'No Result yet, be the first answering this question!',
            context,
            duration: 2,
          );
        }
      });

      setState(() {
        _loadingPolls = false;
      });
    });
  }

  _launchVideo() async {
    final url = widget.question.videoURL;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: SizeConfig.blockSizeVertical * 4.5,
        bottom: SizeConfig.blockSizeVertical * 1.5,
      ),
      margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 0.5),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryAndDate(),
          SizedBox(height: SizeConfig.blockSizeVertical),
          _buildUserInfoAndVoteButtons(),
          SizedBox(height: SizeConfig.blockSizeVertical * 2),
          _buildFeaturedImage(),
          _buildQuestionTitle(context),
          _buildVideoButton(context),
          SizedBox(height: SizeConfig.blockSizeVertical),
          _buildQuestionPoll(context),
          SizedBox(height: SizeConfig.blockSizeVertical),
          _buildDescription(context),
          SizedBox(height: SizeConfig.blockSizeVertical * 2),
          _buildTags(context),
          Divider(thickness: 1, color: Colors.grey.shade200),
          SizedBox(height: SizeConfig.blockSizeVertical * 0.2),
          _buildActionsRow(context),
        ],
      ),
    );
  }

  _buildFeaturedImage() {
    return widget.question.featuredImage != null
        ? GestureDetector(
            onTap: () => showImagePreviewDialog(
              context,
              widget.question.featuredImage,
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: SizeConfig.blockSizeVertical * 30,
                  child: Image.network(
                    '${ApiRepository.FEATURED_IMAGES_PATH}${widget.question.featuredImage}',
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: SizeConfig.blockSizeVertical),
              ],
            ),
          )
        : Container();
  }

  _buildCategoryAndDate() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: Row(
        children: [
          widget.question.category != null
              ? Row(
                  children: [
                    Text(
                      widget.question.category.name,
                      style: TextStyle(
                          fontSize: SizeConfig.safeBlockHorizontal * 3.4),
                    ),
                    Text(
                      ' - ',
                      style: TextStyle(
                          fontSize: SizeConfig.safeBlockHorizontal * 3.4),
                    ),
                  ],
                )
              : Container(),
          Text(
            'Asked at ${formatDate(widget.question.createdAt)}',
            style: TextStyle(
              fontSize: SizeConfig.safeBlockHorizontal * 3.4,
              color: Colors.black54,
            ),
          ),
          Spacer(),
          ReportButton(questionId: widget.question.id),
        ],
      ),
    );
  }

  _buildQuestionTitle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: Text(
        widget.question.title,
        style: TextStyle(
          fontSize: SizeConfig.safeBlockHorizontal * 4.8,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    );
  }

  _buildVideoButton(BuildContext context) {
    return widget.question.videoURL != null
        ? Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal * 6,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: SizeConfig.blockSizeVertical * 2),
                GestureDetector(
                  onTap: _launchVideo,
                  child: Container(
                    width: double.infinity,
                    height: SizeConfig.blockSizeVertical * 6.5,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Theme.of(context).primaryColor.withOpacity(0.6),
                      ),
                      borderRadius: BorderRadius.circular(
                        SizeConfig.safeBlockHorizontal * 10,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.blockSizeHorizontal,
                        vertical: SizeConfig.blockSizeVertical * 1.1,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Watch Video',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Container();
  }

  _buildUserInfoAndVoteButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: Row(
        children: [
          Expanded(
            child:
                UserInfoTile(type: Type.author, author: widget.question.author),
          ),
          VoteButtons(
            questionId: widget.question.id,
            votes: widget.question.votes,
            type: VoteType.question,
          ),
        ],
      ),
    );
  }

  _buildDescription(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: Text(
        widget.question.content,
        style: TextStyle(
          fontSize: SizeConfig.safeBlockHorizontal * 4.1,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
          height: 1.2,
        ),
      ),
    );
  }

  _buildTags(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: widget.question.tags != null
          ? Wrap(
              children: widget.question.tags
                  .map(
                    (tag) => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.blockSizeHorizontal * 2,
                        vertical: SizeConfig.blockSizeVertical,
                      ),
                      margin: EdgeInsets.only(
                        right: SizeConfig.blockSizeHorizontal * 1.2,
                      ),
                      height: SizeConfig.blockSizeVertical * 4,
                      child: Text(
                        '#${tag.tag}',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: SizeConfig.safeBlockHorizontal * 3,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(3)),
                    ),
                  )
                  .toList()
                  .cast<Widget>(),
            )
          : Container(),
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
          SizedBox(
            width: SizeConfig.blockSizeHorizontal * 25,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                primary: !widget.answerBtnEnabled
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade200,
              ),
              onPressed: () {
                if (widget.question.authorId != _authProvider.user.id) {
                  widget.answerQuestion();
                } else {
                  Toast.show('You cannot answer your own question', context);
                }
              },
              child: Text(
                '+ Answer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          SizedBox(width: SizeConfig.blockSizeHorizontal * 10),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  FluentIcons.chat_bubbles_question_20_filled,
                  color: Colors.black54,
                  size: SizeConfig.blockSizeHorizontal * 5.8,
                ),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 2),
                Text(
                  '${widget.question.answersCount}',
                  style: TextStyle(
                    fontSize: SizeConfig.safeBlockHorizontal * 3.4,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 5),
                Icon(
                  Icons.visibility,
                  color: Colors.black54,
                  size: SizeConfig.blockSizeHorizontal * 5.8,
                ),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 2),
                Text(
                  widget.question.views.toString(),
                  style: TextStyle(
                    fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 5),
                widget.question.polled == 1
                    ? Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: Colors.black54,
                            size: SizeConfig.blockSizeHorizontal * 5.8,
                          ),
                          Text(
                            widget.question.userOptionsCount.toString(),
                            style: TextStyle(
                              fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      )
                    : Container(),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 5),
                _authProvider.user != null &&
                        _authProvider.user.id != null &&
                        _authProvider.user.id != widget.question.authorId
                    ? GestureDetector(
                        onTap: () async {
                          setState(() {
                            _isFavorite = !_isFavorite;
                          });
                          await ApiRepository.addToFavorites(
                            context,
                            userId: _authProvider.user.id,
                            questionId: widget.question.id,
                          ).then((value) async {
                            if (!_isFavorite)
                              await Provider.of<AppProvider>(context,
                                      listen: false)
                                  .clearFavoriteQuestions();
                          });
                        },
                        child: Icon(
                          _isFavorite ? Icons.bookmark : Icons.bookmark_border,
                          color: _isFavorite
                              ? Theme.of(context).primaryColor
                              : Colors.black54,
                          size: SizeConfig.blockSizeHorizontal * 6,
                        ),
                      )
                    : Container(),
              ],
            ),
          )
        ],
      ),
    );
  }

  _buildQuestionPoll(BuildContext context) {
    return widget.question.polled == 1
        ? Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal * 5,
              vertical: SizeConfig.blockSizeVertical * 3,
            ),
            color: Colors.grey.shade200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Icon(
                        FluentIcons.question_16_regular,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: SizeConfig.blockSizeHorizontal * 4,
                        ),
                        child: Text(
                          'Participate in poll, Choose your answer',
                          style: TextStyle(
                            fontSize: SizeConfig.safeBlockHorizontal * 4,
                          ),
                        ),
                      ),
                      _loadingPolls
                          ? Container(
                              height: SizeConfig.blockSizeVertical * 20,
                              child: Center(
                                  child: SizedBox(
                                height: SizeConfig.blockSizeVertical * 4,
                                width: SizeConfig.blockSizeVertical * 4,
                                child: CircularProgressIndicator(),
                              )),
                            )
                          : Column(
                              children: [
                                !_showResults
                                    ? widget.question.imagePolled == 0
                                        ? ListView.builder(
                                            shrinkWrap: true,
                                            itemCount:
                                                widget.question.options.length,
                                            itemBuilder: (context, i) =>
                                                QuestionPollListItem(
                                              question: widget.question,
                                              index: i,
                                              selected: _selectedOption ==
                                                      widget.question.options[i]
                                                          .id
                                                  ? true
                                                  : false,
                                              onOptionSelected:
                                                  _onOptionSelected,
                                            ),
                                          )
                                        : Container(
                                            height:
                                                SizeConfig.blockSizeVertical *
                                                    28,
                                            padding: EdgeInsets.only(
                                              left: SizeConfig
                                                      .blockSizeHorizontal *
                                                  4,
                                            ),
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: widget
                                                  .question.options.length,
                                              itemBuilder: (context, i) =>
                                                  QuestionPollImageListItem(
                                                question: widget.question,
                                                index: i,
                                                selected: _selectedOption ==
                                                        widget.question
                                                            .options[i].id
                                                    ? true
                                                    : false,
                                                onOptionSelected:
                                                    _onOptionSelected,
                                              ),
                                            ),
                                          )
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        padding: EdgeInsets.only(
                                          top: SizeConfig.blockSizeVertical,
                                        ),
                                        itemCount:
                                            _resultOptions.options.length,
                                        itemBuilder: (context, i) =>
                                            QuestionPollResultListItem(
                                          option: _resultOptions.options[i],
                                          count: _resultOptions.votesCount,
                                        ),
                                      ),
                                !_showResults
                                    ? Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: SizeConfig
                                                      .blockSizeHorizontal *
                                                  4,
                                              top:
                                                  SizeConfig.blockSizeVertical *
                                                      2,
                                            ),
                                            child: TextButton(
                                              onPressed: () {
                                                if (_authProvider.user !=
                                                        null &&
                                                    _authProvider.user.id !=
                                                        null) {
                                                  _submitOption();
                                                } else {
                                                  Toast.show(
                                                    'You have to login to answer polls',
                                                    context,
                                                    duration: 2,
                                                  );
                                                }
                                              },
                                              style: TextButton.styleFrom(
                                                primary: Theme.of(context)
                                                    .primaryColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(0),
                                                ),
                                              ),
                                              child: Text(
                                                'Submit',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: SizeConfig
                                                      .blockSizeHorizontal *
                                                  2,
                                              top:
                                                  SizeConfig.blockSizeVertical *
                                                      2,
                                            ),
                                            child: TextButton(
                                              onPressed: () =>
                                                  _displayVoteReult(),
                                              style: TextButton.styleFrom(
                                                primary: Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(0),
                                                  side: BorderSide(
                                                    width: 1,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                'Result',
                                                style: TextStyle(
                                                    color: Colors.black54),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Padding(
                                        padding: EdgeInsets.only(
                                          left: SizeConfig.blockSizeHorizontal *
                                              4,
                                          top: SizeConfig.blockSizeVertical * 2,
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Based on ',
                                              style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: SizeConfig
                                                        .safeBlockHorizontal *
                                                    4,
                                              ),
                                            ),
                                            Text(
                                              '(${_resultOptions.votesCount} voters)',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ],
                            ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Container();
  }
}
