import 'package:zapytaj/models/comment.dart';
import 'package:zapytaj/models/question_tag.dart';

import 'category.dart';
import 'option.dart';
import 'user.dart';

class Question {
  int id;
  String type;
  int status;
  String title;
  String titlePlain;
  String content;
  String featuredImage;
  String videoURL;
  int categoryId;
  int authorId;
  int attachmentId;
  int views;
  int votes;
  int answersCount;
  String commentStatus;
  String share;
  int favorite;
  int polled;
  int imagePolled;
  String pollTitle;
  int customFieldId;
  String createdAt;
  String updatedAt;
  Category category;
  List<QuestionTag> tags;
  User author;
  List<Option> options;
  List<Comment> answers;
  // Null attachments;
  // CustomField customFields;

  Question({
    this.id,
    this.type,
    this.status,
    this.title,
    this.titlePlain,
    this.content,
    this.featuredImage,
    this.videoURL,
    this.categoryId,
    this.authorId,
    this.attachmentId,
    this.views,
    this.votes,
    this.answersCount,
    this.commentStatus,
    this.share,
    this.favorite,
    this.polled,
    this.pollTitle,
    this.imagePolled,
    this.customFieldId,
    this.createdAt,
    this.updatedAt,
    this.category,
    this.author,
    this.tags,
    this.options,
    this.answers,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      type: json['type'],
      status: json['status'],
      title: json['title'],
      titlePlain: json['titlePlain'],
      content: json['content'],
      featuredImage: json['featuredImage'],
      videoURL: json['videoURL'],
      categoryId: json['category_id'],
      authorId: json['author_id'],
      attachmentId: json['attachment_id'],
      views: json['views'],
      votes: json['votes'],
      answersCount: json['answersCount'],
      commentStatus: json['commentStatus'],
      share: json['share'],
      favorite: json['favorite'],
      polled: json['polled'],
      imagePolled: json['imagePolled'],
      pollTitle: json['pollTitle'],
      customFieldId: json['custom_field_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      category:
          json['category'] != null ? Category.fromJson(json['category']) : null,
      author: json['user'] != null ? User.fromJson(json['user']) : null,
      tags: json["tags"] != null
          ? List<QuestionTag>.from(
              json["tags"].map((x) => QuestionTag.fromJson(x)))
          : null,
      options: json["options"] != null
          ? List<Option>.from(json["options"].map((x) => Option.fromJson(x)))
          : null,
      answers: json["answers"] != null
          ? List<Comment>.from(json["answers"].map((x) => Comment.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['status'] = this.status;
    data['title'] = this.title;
    data['titlePlain'] = this.titlePlain;
    data['content'] = this.content;
    data['featuredImage'] = this.featuredImage;
    data['videoURL'] = this.videoURL;
    data['category_id'] = this.categoryId;
    data['author_id'] = this.authorId;
    data['attachment_id'] = this.attachmentId;
    data['views'] = this.views;
    data['votes'] = this.votes;
    data['answersCount'] = this.answersCount;
    data['answers'] = this.answers;
    data['commentStatus'] = this.commentStatus;
    data['share'] = this.share;
    data['favorite'] = this.favorite;
    data['polled'] = this.polled;
    data['pollTitle'] = this.pollTitle;
    data['imagePolled'] = this.imagePolled;
    data['custom_field_id'] = this.customFieldId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
