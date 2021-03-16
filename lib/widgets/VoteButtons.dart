import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:zapytaj/providers/AppProvider.dart';
import 'package:zapytaj/providers/AuthProvider.dart';
import 'package:zapytaj/services/ApiRepository.dart';

import '../config/SizeConfig.dart';

enum VoteType { comment, question }

class VoteButtons extends StatefulWidget {
  final int votes;
  final int questionId;
  final int commentId;
  final VoteType type;
  final int userId;
  final Function updateVotes;
  final String endpoint;

  const VoteButtons({
    Key key,
    this.votes = 0,
    this.questionId,
    this.commentId,
    this.type,
    this.userId,
    this.updateVotes,
    this.endpoint,
  }) : super(key: key);

  @override
  _VoteButtonsState createState() => _VoteButtonsState();
}

class _VoteButtonsState extends State<VoteButtons> {
  AppProvider _appProvider;
  bool _isLoading = false;
  int _votes = 0;

  _getVotes() async {
    switch (widget.type) {
      case VoteType.question:
        await ApiRepository.getQuestionVotes(context,
                questionId: widget.questionId)
            .then((votes) {
          setState(() {
            _votes = votes;
          });
        });
        print(_appProvider.recentQuestions.length);
        if (widget.endpoint != null) _updateValueInProvider();
        widget.updateVotes();
        break;
      case VoteType.comment:
        await ApiRepository.getCommentVotes(context,
                commentId: widget.commentId)
            .then((votes) {
          setState(() {
            _votes = votes;
          });
        });
        break;
    }

    // _appProvider.clearQuestions();
  }

  _updateValueInProvider() {
    switch (widget.endpoint) {
      case 'recentQuestions':
        _appProvider.recentQuestions
            .firstWhere((q) => q.id == widget.questionId)
            .votes = _votes;
        _appProvider.clearMostAnsweredQuestions();
        _appProvider.clearMostVisitedQuestions();
        _appProvider.clearMostVotedQuestions();
        _appProvider.clearNoAnswersQuestions();
        break;
      case 'mostAnsweredQuestions':
        _appProvider.mostAnsweredQuestions
            .firstWhere((q) => q.id == widget.questionId)
            .votes = _votes;
        _appProvider.clearRecentQuestions();
        _appProvider.clearMostVisitedQuestions();
        _appProvider.clearMostVotedQuestions();
        _appProvider.clearNoAnswersQuestions();
        break;
      case 'mostVisitedQuestions':
        _appProvider.mostVisitedQuestions
            .firstWhere((q) => q.id == widget.questionId)
            .votes = _votes;
        _appProvider.clearMostAnsweredQuestions();
        _appProvider.clearRecentQuestions();
        _appProvider.clearMostVotedQuestions();
        _appProvider.clearNoAnswersQuestions();
        break;
      case 'mostVotedQuestions':
        _appProvider.mostVotedQuestions
            .firstWhere((q) => q.id == widget.questionId)
            .votes = _votes;
        _appProvider.clearMostAnsweredQuestions();
        _appProvider.clearRecentQuestions();
        _appProvider.clearMostVisitedQuestions();
        _appProvider.clearNoAnswersQuestions();
        break;
      case 'noAnsweredQuestions':
        _appProvider.noAnswersQuestions
            .firstWhere((q) => q.id == widget.questionId)
            .votes = _votes;
        _appProvider.clearMostAnsweredQuestions();
        _appProvider.clearRecentQuestions();
        _appProvider.clearMostVotedQuestions();
        _appProvider.clearMostVisitedQuestions();
        break;
      default:
        return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _appProvider = Provider.of<AppProvider>(context, listen: false);
    // _getVotes();
    // setState(() {
    if (widget.type == VoteType.comment) _getVotes();
    // });
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);
    return Container(
        // width: SizeConfig.blockSizeHorizontal * 32,
        child:
            //  !_isLoading
            //     ?
            Row(
      children: [
        _arrowButton(Icons.arrow_drop_up, () async {
          if (auth.user != null && auth.user.id != null) {
            if (!_isLoading) {
              setState(() {
                _isLoading = true;
              });

              switch (widget.type) {
                case VoteType.comment:
                  if (auth.user == null) {
                    await ApiRepository.voteComment(
                      context,
                      commentId: widget.commentId,
                      userId: 0,
                      vote: 1,
                    );
                  } else if (widget.userId != auth.user.id)
                    await ApiRepository.voteComment(
                      context,
                      commentId: widget.commentId,
                      userId: auth.user != null ? auth.user.id : 0,
                      vote: 1,
                    );
                  else {
                    Toast.show(
                      'Sorry, you cannot vote your answer',
                      context,
                      duration: 2,
                    );
                    setState(() {
                      _isLoading = false;
                    });
                  }
                  break;
                case VoteType.question:
                  if (auth.user == null) {
                    await ApiRepository.voteQuestion(
                      context,
                      questionId: widget.questionId,
                      userId: 0,
                      vote: 1,
                    );
                  } else if (widget.userId != auth.user.id) {
                    await ApiRepository.voteQuestion(
                      context,
                      questionId: widget.questionId,
                      userId: auth.user != null ? auth.user.id : 0,
                      vote: 1,
                    );
                  } else {
                    Toast.show(
                      'Sorry, you cannot vote your question',
                      context,
                      duration: 2,
                    );
                    setState(() {
                      _isLoading = false;
                    });
                  }
                  break;
              }
              await _getVotes();
              setState(() {
                _isLoading = false;
              });
            }
          } else {
            Toast.show('You have to login to vote questions', context,
                duration: 2);
          }
        }),
        SizedBox(width: SizeConfig.blockSizeHorizontal * 2.7),
        !_isLoading
            ? Text(
                // _votes != null ? _votes.toString() : '0',
                VoteType.question == widget.type
                    ? widget.votes != null
                        ? widget.votes.toString()
                        : '0'
                    : _votes != null
                        ? _votes.toString()
                        : '0',
                style:
                    TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 3.6),
              )
            : SizedBox(
                width: SizeConfig.blockSizeHorizontal * 5,
                height: SizeConfig.blockSizeHorizontal * 5,
                child: CircularProgressIndicator(),
              ),
        SizedBox(width: SizeConfig.blockSizeHorizontal * 2.7),
        _arrowButton(Icons.arrow_drop_down, () async {
          if (auth.user != null && auth.user.id != null) {
            if (!_isLoading) {
              setState(() {
                _isLoading = true;
              });

              switch (widget.type) {
                case VoteType.comment:
                  if (auth.user == null) {
                    await ApiRepository.voteComment(
                      context,
                      commentId: widget.commentId,
                      userId: 0,
                      vote: -1,
                    );
                  } else if (widget.userId != auth.user.id)
                    await ApiRepository.voteComment(
                      context,
                      commentId: widget.commentId,
                      userId: auth.user.id,
                      vote: -1,
                    );
                  else {
                    Toast.show(
                      'Sorry, you cannot vote your answer',
                      context,
                      duration: 2,
                    );
                    setState(() {
                      _isLoading = false;
                    });
                  }
                  break;
                case VoteType.question:
                  if (auth.user == null) {
                    await ApiRepository.voteQuestion(
                      context,
                      questionId: widget.questionId,
                      userId: 0,
                      vote: -1,
                    );
                  } else if (widget.userId != auth.user.id)
                    await ApiRepository.voteQuestion(
                      context,
                      questionId: widget.questionId,
                      userId: auth.user.id,
                      vote: -1,
                    );
                  else {
                    Toast.show(
                      'Sorry, you cannot vote your question',
                      context,
                      duration: 2,
                    );
                    setState(() {
                      _isLoading = false;
                    });
                  }
                  break;
              }
              await _getVotes();
              setState(() {
                _isLoading = false;
              });
            }
          } else {
            Toast.show('You have to login to vote questions', context,
                duration: 2);
          }
        }),
      ],
    )
        // : Expanded(
        //     child: Center(
        //       child: SizedBox(
        //         width: SizeConfig.blockSizeHorizontal * 5,
        //         height: SizeConfig.blockSizeHorizontal * 5,
        //         child: CircularProgressIndicator(),
        //       ),
        //     ),
        //   ),
        );
  }

  _arrowButton(IconData icon, Function onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: SizeConfig.blockSizeHorizontal * 11.5,
        height: SizeConfig.blockSizeHorizontal * 11.5,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(icon, size: 20, color: Colors.black54),
      ),
    );
  }
}
