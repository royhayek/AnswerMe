import 'package:zapytaj/models/category.dart';

class CategoryResponse {
  bool status;
  int total;
  int pages;
  int count;
  List<Category> categories;

  CategoryResponse(
      {this.status, this.total, this.pages, this.count, this.categories});

  CategoryResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    total = json['total'];
    pages = json['pages'];
    count = json['count'];
    if (json['categories'] != null) {
      categories = new List<Category>();
      json['categories'].forEach((v) {
        categories.add(new Category.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['total'] = this.total;
    data['pages'] = this.pages;
    data['count'] = this.count;
    if (this.categories != null) {
      data['categories'] = this.categories.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
