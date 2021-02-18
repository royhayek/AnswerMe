import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapytaj/providers/auth_provider.dart';
import 'package:zapytaj/services/api_repository.dart';

import '../config/size_config.dart';

class VoteButtons extends StatefulWidget {
  final int votes;
  final int questionId;

  const VoteButtons({Key key, this.votes, this.questionId}) : super(key: key);

  @override
  _VoteButtonsState createState() => _VoteButtonsState();
}

class _VoteButtonsState extends State<VoteButtons> {
  bool _isLoading = false;
  int _votes = 0;

  _getVotes() async {
    await ApiRepository.getQuestionVotes(context, questionId: widget.questionId)
        .then((votes) {
      setState(() {
        _votes = votes;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    _votes = widget.votes;
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);
    return Container(
      // width: SizeConfig.blockSizeHorizontal * 32,
      child: !_isLoading
          ? Row(
              children: [
                _arrowButton(Icons.arrow_drop_up, () async {
                  setState(() {
                    _isLoading = true;
                  });
                  await ApiRepository.voteQuestion(
                    context,
                    questionId: widget.questionId,
                    userId: auth.user.id,
                    vote: 1,
                  );
                  await _getVotes();
                  setState(() {
                    _isLoading = false;
                  });
                }),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 2.7),
                Text(
                  _votes.toString(),
                  style:
                      TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 3.6),
                ),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 2.7),
                _arrowButton(Icons.arrow_drop_down, () async {
                  setState(() {
                    _isLoading = true;
                  });
                  await ApiRepository.voteQuestion(
                    context,
                    questionId: widget.questionId,
                    userId: auth.user.id,
                    vote: -1,
                  );
                  await _getVotes();
                  setState(() {
                    _isLoading = false;
                  });
                }),
              ],
            )
          : Center(
              child: SizedBox(
                  width: SizeConfig.blockSizeHorizontal * 5,
                  height: SizeConfig.blockSizeHorizontal * 5,
                  child: CircularProgressIndicator())),
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
