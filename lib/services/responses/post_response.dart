import 'package:zapytaj/models/question.dart';

class PostResponse {
  bool status;
  int count;
  int countTotal;
  int pages;
  List<Question> posts;

  PostResponse(
      {this.status, this.count, this.countTotal, this.pages, this.posts});

  PostResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    count = json['count'];
    countTotal = json['count_total'];
    pages = json['pages'];
    if (json['posts'] != null) {
      posts = new List<Question>();
      json['posts'].forEach((v) {
        posts.add(new Question.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['count'] = this.count;
    data['count_total'] = this.countTotal;
    data['pages'] = this.pages;
    if (this.posts != null) {
      data['posts'] = this.posts.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
