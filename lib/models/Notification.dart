class Notification {
  int id;
  int userId;
  String title;
  String message;
  int questionId;
  int authorId;
  String createdAt;
  String updatedAt;

  Notification(
      {this.id,
      this.userId,
      this.title,
      this.message,
      this.questionId,
      this.authorId,
      this.createdAt,
      this.updatedAt});

  Notification.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    title = json['title'];
    message = json['message'];
    questionId = json['question_id'];
    authorId = json['author_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['title'] = this.title;
    data['message'] = this.message;
    data['question_id'] = this.questionId;
    data['author_id'] = this.authorId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
