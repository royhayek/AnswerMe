import 'package:zapytaj/models/user.dart';

class Comment {
  int id;
  String type;
  int authorId;
  int answerId;
  int questionId;
  String content;
  String date;
  String featuredImage;
  int votes;
  String createdAt;
  String updatedAt;
  User author;
  List<Comment> replies;

  Comment({
    this.id,
    this.type,
    this.authorId,
    this.answerId,
    this.questionId,
    this.content,
    this.date,
    this.votes,
    this.featuredImage,
    this.createdAt,
    this.updatedAt,
    this.author,
    this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      type: json['type'],
      authorId: json['author_id'],
      date: json['date'],
      content: json['content'],
      votes: json['votes'],
      featuredImage: json['featuredImage'],
      answerId: json['answer_id'],
      questionId: json['question_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      author: json['user'] != null ? User.fromJson(json['user']) : null,
      replies: json["replies"] != null
          ? List<Comment>.from(json["replies"].map((x) => Comment.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['author_id'] = this.authorId;
    data['date'] = this.date;
    data['votes'] = this.votes;
    data['featuredImage'] = this.featuredImage;
    data['content'] = this.content;
    data['answer_id'] = this.answerId;
    data['question_id'] = this.questionId;
    data['user'] = this.author;
    data['replies'] = List<dynamic>.from(this.replies.map((x) => x.toJson()));
    return data;
  }
}
