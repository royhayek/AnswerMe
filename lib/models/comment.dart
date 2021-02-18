import 'package:zapytaj/models/user.dart';

class Comment {
  int id;
  String type;
  int authorId;
  int replierId;
  int questionId;
  String content;
  String date;
  String createdAt;
  String updatedAt;
  User author;

  Comment({
    this.id,
    this.type,
    this.authorId,
    this.replierId,
    this.questionId,
    this.content,
    this.date,
    this.createdAt,
    this.updatedAt,
    this.author,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      type: json['type'],
      authorId: json['author_id'],
      date: json['date'],
      content: json['content'],
      replierId: json['replier_id'],
      questionId: json['question_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      author: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['author_id'] = this.authorId;
    data['date'] = this.date;
    data['content'] = this.content;
    data['replier_id'] = this.replierId;
    data['question_id'] = this.questionId;
    data['user'] = this.author;
    return data;
  }
}
