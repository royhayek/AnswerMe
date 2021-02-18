import 'package:zapytaj/models/question.dart';

import 'package:zapytaj/models/tag.dart';

class TagPostsResponse {
  bool status;
  int count;
  int countTotal;
  int pages;
  Tag tag;
  List<Question> posts;

  TagPostsResponse(
      {this.status,
      this.count,
      this.countTotal,
      this.pages,
      this.tag,
      this.posts});

  TagPostsResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    count = json['count'];
    countTotal = json['count_total'];
    pages = json['pages'];
    tag = json['tag'] != null ? new Tag.fromJson(json['tag']) : null;
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
    if (this.tag != null) {
      data['tag'] = this.tag.toJson();
    }
    if (this.posts != null) {
      data['posts'] = this.posts.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
