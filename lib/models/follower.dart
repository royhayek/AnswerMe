class Follower {
  int id;
  int userId;
  int categoryId;

  Follower({
    this.id,
    this.userId,
    this.categoryId,
  });

  factory Follower.fromJson(Map<String, dynamic> json) {
    return Follower(
      id: json['id'],
      userId: json['user_id'],
      categoryId: json['category_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['category_id'] = this.categoryId;
    return data;
  }
}
