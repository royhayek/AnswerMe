import 'package:zapytaj/models/user.dart';

class FollowResponse {
  String status;
  int count;
  int pages;
  List<User> users;

  FollowResponse({
    this.status,
    this.count,
    this.pages,
    this.users,
  });

  FollowResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    count = json['count'];
    pages = json['pages'];
    if (json['comments'] != null) {
      users = new List<User>();
      json['comments'].forEach((v) {
        users.add(new User.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['count'] = this.count;
    data['pages'] = this.pages;
    if (this.users != null) {
      data['users'] = this.users.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
