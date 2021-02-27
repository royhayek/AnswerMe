import 'package:provider/provider.dart';
import 'package:zapytaj/models/question.dart';
import 'package:zapytaj/providers/app_provider.dart';
import 'package:zapytaj/providers/auth_provider.dart';
import 'package:zapytaj/screens/other/postDetail.dart';
import 'package:zapytaj/config/size_config.dart';
import 'package:zapytaj/services/api_repository.dart';
import 'package:zapytaj/utils/utils.dart';
import 'package:zapytaj/widgets/report_button.dart';
import 'package:zapytaj/widgets/user_info_tile.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:zapytaj/widgets/vote_buttons.dart';

class PostListItem extends StatefulWidget {
  final Question question;
  final Function addToFav;
  final Function removeFromFav;

  const PostListItem(
      {Key key, this.question, this.addToFav, this.removeFromFav})
      : super(key: key);

  @override
  _PostListItemState createState() => _PostListItemState();
}

class _PostListItemState extends State<PostListItem> {
  bool _isFavorite = false;
  AuthProvider _authProvider;

  _navigateToPostDetail(BuildContext context, {bool answer = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => PostDetailScreen(
          question: widget.question,
          answerBtnEnabled: answer,
        ),
      ),
    );
  }

  _checkIfIsFavorite() {
    ApiRepository.checkIfIsFavorite(
      context,
      userId: _authProvider.user != null ? _authProvider.user.id : 0,
      questionId: widget.question.id,
    ).then((favorite) {
      if (mounted)
        setState(() {
          _isFavorite = favorite;
        });
    });
  }

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (widget.question.favorite == 1)
      _isFavorite = true;
    else
      _isFavorite = false;
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   _checkIfIsFavorite();
  // }

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);
    return Container(
      padding: EdgeInsets.fromLTRB(
        0,
        SizeConfig.blockSizeVertical * 4,
        0,
        SizeConfig.blockSizeVertical * 1.5,
      ),
      margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 0.5),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryAndDate(auth),
          SizedBox(height: SizeConfig.blockSizeVertical),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal * 6,
            ),
            child: Row(
              children: [
                Expanded(
                  child: UserInfoTile(
                      type: Type.author, author: widget.question.author),
                ),
                VoteButtons(
                  votes: widget.question.votes,
                  questionId: widget.question.id,
                  type: VoteType.question,
                ),
              ],
            ),
          ),

          SizedBox(height: SizeConfig.blockSizeVertical * 2),
          _buildFeaturedImage(context),
          _buildPostTitle(context),
          SizedBox(height: SizeConfig.blockSizeVertical * 2),
          // _buildQuestionPoll(context),
          // SizedBox(height: SizeConfig.blockSizeVertical),
          _buildDescription(context),
          SizedBox(height: SizeConfig.blockSizeVertical * 2),
          _buildTags(context),
          Divider(thickness: 1, color: Colors.grey.shade200),
          SizedBox(height: SizeConfig.blockSizeVertical * 0.2),
          _buildActionsRow(context, auth),
        ],
      ),
    );
  }

  _buildFeaturedImage(BuildContext context) {
    return widget.question.featuredImage != null
        ? Column(
            children: [
              GestureDetector(
                onTap: () => _navigateToPostDetail(context),
                child: SizedBox(
                  width: double.infinity,
                  height: SizeConfig.blockSizeVertical * 30,
                  child: Image.network(
                    '${ApiRepository.FEATURED_IMAGES_PATH}${widget.question.featuredImage}',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: SizeConfig.blockSizeVertical),
            ],
          )
        : Container();
  }

  _buildCategoryAndDate(AuthProvider auth) {
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
          auth.user != null && auth.user.id != widget.question.authorId
              ? ReportButton(questionId: widget.question.id)
              : SizedBox(height: SizeConfig.blockSizeVertical * 4),
        ],
      ),
    );
  }

  _buildPostTitle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: GestureDetector(
        onTap: () => _navigateToPostDetail(context),
        child: Text(
          widget.question.title,
          style: TextStyle(
            fontSize: SizeConfig.safeBlockHorizontal * 4.8,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  _buildDescription(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: GestureDetector(
        onTap: () => _navigateToPostDetail(context),
        child: Text(
          widget.question.content,
          style: TextStyle(
            fontSize: SizeConfig.safeBlockHorizontal * 4.1,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
            height: 1.2,
          ),
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

  _buildActionsRow(BuildContext context, AuthProvider auth) {
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
              onPressed: () => _navigateToPostDetail(context, answer: true),
              color: Theme.of(context).primaryColor,
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  Icons.visibility,
                  color: Colors.black54,
                  size: SizeConfig.blockSizeHorizontal * 5.8,
                ),
                Text(
                  widget.question.views.toString(),
                  style: TextStyle(
                    fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 2),
                Icon(
                  FluentIcons.chat_bubbles_question_20_filled,
                  color: Colors.black54,
                  size: SizeConfig.blockSizeHorizontal * 5.8,
                ),
                GestureDetector(
                  onTap: () => _navigateToPostDetail(context),
                  child: Text(
                    '${widget.question.answersCount} Answers',
                    style: TextStyle(
                      fontSize: SizeConfig.safeBlockHorizontal * 3.4,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 2.5),
                _authProvider.user != null
                    ? GestureDetector(
                        onTap: () async {
                          setState(() {
                            _isFavorite = !_isFavorite;
                          });
                          await ApiRepository.addToFavorites(
                            context,
                            userId: auth.user.id,
                            questionId: widget.question.id,
                          ).then((value) async {
                            if (!_isFavorite)
                              await widget.removeFromFav(widget.question.id);
                            else {
                              await widget.addToFav(widget.question.id);
                              await Provider.of<AppProvider>(context,
                                      listen: false)
                                  .clearFavoriteQuestions();
                            }
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
}
