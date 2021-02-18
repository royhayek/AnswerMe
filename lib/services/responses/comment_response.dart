import 'package:zapytaj/models/comment.dart';

class CommentResponse {
  bool status;
  List<Comment> comments;

  CommentResponse({this.status, this.comments});

  CommentResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['comments'] != null) {
      comments = new List<Comment>();
      json['comments'].forEach((v) {
        comments.add(new Comment.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.comments != null) {
      data['comments'] = this.comments.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
