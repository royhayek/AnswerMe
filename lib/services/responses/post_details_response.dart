import 'package:zapytaj/models/question.dart';

class PostDetailsResponse {
  bool status;
  Question post;
  String previousUrl;

  PostDetailsResponse({this.status, this.post, this.previousUrl});

  PostDetailsResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    post = json['post'] != null ? new Question.fromJson(json['post']) : null;
    previousUrl = json['previous_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.post != null) {
      data['post'] = this.post.toJson();
    }
    data['previous_url'] = this.previousUrl;
    return data;
  }
}
