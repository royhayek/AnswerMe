import 'package:zapytaj/models/question.dart';
import 'package:zapytaj/config/size_config.dart';
import 'package:zapytaj/utils/utils.dart';
import 'package:zapytaj/widgets/post_poll_image_list_item.dart';
import 'package:zapytaj/widgets/post_poll_list_item.dart';
import 'package:zapytaj/widgets/report_button.dart';
import 'package:zapytaj/widgets/user_info_tile.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:zapytaj/widgets/vote_buttons.dart';

class PostDetailItem extends StatelessWidget {
  final Question question;
  final Function answerQuestion;
  final bool answerBtnEnabled;

  const PostDetailItem(
      {Key key, this.question, this.answerQuestion, this.answerBtnEnabled})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(question.category);
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
          _buildPostTitle(context),
          SizedBox(height: SizeConfig.blockSizeVertical * 2),
          _buildUserInfoAndVoteButtons(),
          SizedBox(height: SizeConfig.blockSizeVertical * 2),
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

  _buildCategoryAndDate() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: Row(
        children: [
          Text(
            question.category.name,
            style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 3.4),
          ),
          Text(
            ' - ',
            style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 3.4),
          ),
          Text(
            'Asked at ${formatDate(question.createdAt)}',
            style: TextStyle(
              fontSize: SizeConfig.safeBlockHorizontal * 3.4,
              color: Colors.black54,
            ),
          ),
          Spacer(),
          ReportButton(),
        ],
      ),
    );
  }

  _buildPostTitle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: Text(
        question.title,
        style: TextStyle(
          fontSize: SizeConfig.safeBlockHorizontal * 4.8,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    );
  }

  _buildUserInfoAndVoteButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: Row(
        children: [
          Expanded(
            child: UserInfoTile(type: Type.author, author: question.author),
          ),
          VoteButtons(questionId: question.id, votes: question.votes),
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
        question.content,
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
      child: question.tags != null
          ? Wrap(
              children: question.tags
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
    print('answerBtnEnabled: $answerBtnEnabled');
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: SizeConfig.blockSizeHorizontal * 25,
            child: RaisedButton(
              elevation: 0,
              onPressed: () => answerQuestion(),
              color: !answerBtnEnabled
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade200,
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
                  '${question.answersCount}',
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
                  question.views.toString(),
                  style: TextStyle(
                    fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 5),
                Icon(
                  Icons.bookmark_border,
                  color: Colors.black54,
                  size: SizeConfig.blockSizeHorizontal * 6,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  _buildQuestionPoll(BuildContext context) {
    return question.polled == 1
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
                      question.imagePolled == 0
                          ? ListView.builder(
                              shrinkWrap: true,
                              itemCount: question.options.length,
                              itemBuilder: (context, i) => PostPollListItem(
                                question: question,
                                index: i,
                              ),
                            )
                          : Container(
                              height: SizeConfig.blockSizeVertical * 28,
                              padding: EdgeInsets.only(
                                left: SizeConfig.blockSizeHorizontal * 4,
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: question.options.length,
                                itemBuilder: (context, i) =>
                                    PostPollImageListItem(
                                  question: question,
                                  index: i,
                                ),
                              ),
                            ),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              left: SizeConfig.blockSizeHorizontal * 4,
                              top: SizeConfig.blockSizeVertical * 2,
                            ),
                            child: FlatButton(
                              onPressed: () => null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child: Text(
                                'Submit',
                                style: TextStyle(color: Colors.white),
                              ),
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: SizeConfig.blockSizeHorizontal * 2,
                              top: SizeConfig.blockSizeVertical * 2,
                            ),
                            child: FlatButton(
                              onPressed: () => null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                                side: BorderSide(
                                  width: 1,
                                  color: Colors.black54,
                                ),
                              ),
                              child: Text(
                                'Result',
                                style: TextStyle(color: Colors.black54),
                              ),
                              color: Colors.transparent,
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
