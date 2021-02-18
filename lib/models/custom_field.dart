class CustomField {
  List<String> questionPoll;
  List<String> rememberAnswer;
  List<String> videoType;
  List<String> postStats;
  List<String> questionVote;
  List<String> countPostAll;
  List<String> countPostComments;
  List<String> postFromFront;
  List<String> discyLayout;
  List<String> discyHomeTemplate;
  List<String> discySiteSkinL;
  List<String> discySkin;
  List<String> discySidebar;
  List<String> postApprovedBefore;
  List<String> getPointsBefore;
  List<String> commentCount;
  List<String> wpqaQuestionVoteUp;
  List<String> wpqaQuestionVoteUpMobile;
  List<String> wpqaQuestionVoteDown;
  List<String> wpqaQuestionVoteDownMobile;
  int favoritesQuestions;
  List<String> questionFavorites;
  List<Null> wpqaQuestionPoll;

  CustomField(
      {this.questionPoll,
      this.rememberAnswer,
      this.videoType,
      this.postStats,
      this.questionVote,
      this.countPostAll,
      this.countPostComments,
      this.postFromFront,
      this.discyLayout,
      this.discyHomeTemplate,
      this.discySiteSkinL,
      this.discySkin,
      this.discySidebar,
      this.postApprovedBefore,
      this.getPointsBefore,
      this.commentCount,
      this.wpqaQuestionVoteUp,
      this.wpqaQuestionVoteUpMobile,
      this.wpqaQuestionVoteDown,
      this.wpqaQuestionVoteDownMobile,
      this.favoritesQuestions,
      this.questionFavorites,
      this.wpqaQuestionPoll});

  CustomField.fromJson(Map<String, dynamic> json) {
    questionPoll = json['question_poll'].cast<String>();
    rememberAnswer = json['remember_answer'].cast<String>();
    videoType = json['video_type'].cast<String>();
    postStats = json['post_stats'].cast<String>();
    questionVote = json['question_vote'].cast<String>();
    countPostAll = json['count_post_all'].cast<String>();
    countPostComments = json['count_post_comments'].cast<String>();
    postFromFront = json['post_from_front'].cast<String>();
    discyLayout = json['discy_layout'].cast<String>();
    discyHomeTemplate = json['discy_home_template'].cast<String>();
    discySiteSkinL = json['discy_site_skin_l'].cast<String>();
    discySkin = json['discy_skin'].cast<String>();
    discySidebar = json['discy_sidebar'].cast<String>();
    postApprovedBefore = json['post_approved_before'].cast<String>();
    getPointsBefore = json['get_points_before'].cast<String>();
    commentCount = json['comment_count'].cast<String>();
    wpqaQuestionVoteUp = json['wpqa_question_vote_up'].cast<String>();
    wpqaQuestionVoteUpMobile =
        json['wpqa_question_vote_up_mobile'].cast<String>();
    wpqaQuestionVoteDown = json['wpqa_question_vote_down'].cast<String>();
    wpqaQuestionVoteDownMobile =
        json['wpqa_question_vote_down_mobile'].cast<String>();
    favoritesQuestions = json['favorites_questions'];
    questionFavorites = json['question_favorites'].cast<String>();
    if (json['wpqa_question_poll'] != null) {
      wpqaQuestionPoll = new List<String>();
      json['wpqa_question_poll'].forEach((v) {
        wpqaQuestionPoll.add(v);
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['question_poll'] = this.questionPoll;
    data['remember_answer'] = this.rememberAnswer;
    data['video_type'] = this.videoType;
    data['post_stats'] = this.postStats;
    data['question_vote'] = this.questionVote;
    data['count_post_all'] = this.countPostAll;
    data['count_post_comments'] = this.countPostComments;
    data['post_from_front'] = this.postFromFront;
    data['discy_layout'] = this.discyLayout;
    data['discy_home_template'] = this.discyHomeTemplate;
    data['discy_site_skin_l'] = this.discySiteSkinL;
    data['discy_skin'] = this.discySkin;
    data['discy_sidebar'] = this.discySidebar;
    data['post_approved_before'] = this.postApprovedBefore;
    data['get_points_before'] = this.getPointsBefore;
    data['comment_count'] = this.commentCount;
    data['wpqa_question_vote_up'] = this.wpqaQuestionVoteUp;
    data['wpqa_question_vote_up_mobile'] = this.wpqaQuestionVoteUpMobile;
    data['wpqa_question_vote_down'] = this.wpqaQuestionVoteDown;
    data['wpqa_question_vote_down_mobile'] = this.wpqaQuestionVoteDownMobile;
    data['favorites_questions'] = this.favoritesQuestions;
    data['question_favorites'] = this.questionFavorites;
    if (this.wpqaQuestionPoll != null) {
      data['wpqa_question_poll'] = this.wpqaQuestionPoll.map((v) => v).toList();
    }
    return data;
  }
}
