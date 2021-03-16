import 'package:admob_flutter/admob_flutter.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:zapytaj/config/AdmobConfig.dart';
import 'package:zapytaj/models/question.dart';
import 'package:zapytaj/providers/AppProvider.dart';
import 'package:zapytaj/providers/AuthProvider.dart';
import 'package:zapytaj/screens/other/QuestionDetail.dart';
import 'package:zapytaj/config/SizeConfig.dart';
import 'package:zapytaj/services/ApiRepository.dart';
import 'package:zapytaj/utils/utils.dart';
import 'package:zapytaj/widgets/ReportButton.dart';
import 'package:zapytaj/widgets/UserInfoTile.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:zapytaj/widgets/VoteButtons.dart';

class QuestionListItem extends StatefulWidget {
  final Question question;
  final Function addToFav;
  final Function removeFromFav;
  final String endpoint;

  const QuestionListItem(
      {Key key,
      this.question,
      this.addToFav,
      this.removeFromFav,
      this.endpoint})
      : super(key: key);

  @override
  _QuestionListItemState createState() => _QuestionListItemState();
}

class _QuestionListItemState extends State<QuestionListItem> {
  AdmobInterstitial interstitialAd = AdmobInterstitial(
    adUnitId: AdmobConfig.interstitualAdUnitId,
  );
  bool _isFavorite = false;
  AuthProvider _authProvider;
  AppProvider _appProvider;

  _navigateToQuestionDetail(BuildContext context, {bool answer = false}) async {
    await _appProvider.incrementAdClickCount();
    print(_appProvider.adClickCount);
    if (_appProvider.adClickCount > 9) {
      if (await interstitialAd.isLoaded) {
        interstitialAd.show();
      } else {
        print('Interstitial ad is still loading...');
      }
      await _appProvider.resetAdClickCount();
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => QuestionDetailScreen(
          questionId: widget.question.id,
          answerBtnEnabled: answer,
        ),
      ),
    );
  }

  _updateVotes() {
    setState(() {});
  }

  // _checkIfIsFavorite() {
  //   ApiRepository.checkIfIsFavorite(
  //     context,
  //     userId: _authProvider.user != null ? _authProvider.user.id : 0,
  //     questionId: widget.question.id,
  //   ).then((favorite) {
  //     if (mounted)
  //       setState(() {
  //         _isFavorite = favorite;
  //       });
  //   });
  // }

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _appProvider = Provider.of<AppProvider>(context, listen: false);

    interstitialAd = AdmobInterstitial(
      adUnitId: AdmobConfig.interstitualAdUnitId,
      listener: (AdmobAdEvent event, Map<String, dynamic> args) {
        if (event == AdmobAdEvent.closed) interstitialAd.load();
      },
    );

    interstitialAd.load();

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
                    type: Type.author,
                    author: widget.question.author,
                  ),
                ),
                VoteButtons(
                  votes: widget.question.votes,
                  questionId: widget.question.id,
                  type: VoteType.question,
                  userId: widget.question.authorId,
                  updateVotes: _updateVotes,
                  endpoint: widget.endpoint,
                ),
              ],
            ),
          ),
          SizedBox(height: SizeConfig.blockSizeVertical * 2),
          _buildFeaturedImage(context),
          _buildQuestionTitle(context),
          SizedBox(height: SizeConfig.blockSizeVertical * 2),
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
                onTap: () => _navigateToQuestionDetail(context),
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

  _buildQuestionTitle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: GestureDetector(
        onTap: () => _navigateToQuestionDetail(context),
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
        onTap: () => _navigateToQuestionDetail(context),
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
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                primary: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                if (auth.user != null && auth.user.id != null) {
                  if (widget.question.authorId != auth.user.id) {
                    _navigateToQuestionDetail(context, answer: true);
                  } else {
                    Toast.show(
                      'You cannot answer your own question',
                      context,
                      duration: 2,
                    );
                  }
                } else {
                  Toast.show(
                    'You have to login to answer questions',
                    context,
                    duration: 2,
                  );
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
          SizedBox(width: SizeConfig.blockSizeHorizontal * 7),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                // SizedBox(width: SizeConfig.blockSizeHorizontal * 2),
                Icon(
                  FluentIcons.chat_bubbles_question_20_filled,
                  color: Colors.black54,
                  size: SizeConfig.blockSizeHorizontal * 5.8,
                ),
                GestureDetector(
                  onTap: () => _navigateToQuestionDetail(context),
                  child: Text(
                    '${widget.question.answersCount != null ? widget.question.answersCount : 0} Answers',
                    style: TextStyle(
                      fontSize: SizeConfig.safeBlockHorizontal * 3.4,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ),
                // SizedBox(width: SizeConfig.blockSizeHorizontal * 2),
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
                SizedBox(width: SizeConfig.blockSizeHorizontal),
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
