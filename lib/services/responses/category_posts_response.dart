import 'package:zapytaj/models/category.dart';
import 'package:zapytaj/models/question.dart';

class CategoryPostsResponse {
  bool status;
  int count;
  int countTotal;
  int pages;
  Category category;
  List<Question> posts;

  CategoryPostsResponse(
      {this.status,
      this.count,
      this.countTotal,
      this.pages,
      this.category,
      this.posts});

  CategoryPostsResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    count = json['count'];
    countTotal = json['count_total'];
    pages = json['pages'];
    category = json['category'] != null
        ? new Category.fromJson(json['category'])
        : null;
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
    if (this.category != null) {
      data['category'] = this.category.toJson();
    }
    if (this.posts != null) {
      data['posts'] = this.posts.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
