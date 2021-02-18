class Option {
  int id;
  int questionId;
  String option;
  String image;
  String createdAt;
  String updatedAt;

  Option({
    this.id,
    this.questionId,
    this.option,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'],
      questionId: json['question_id'],
      option: json['option'],
      image: json['image'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['question_id'] = this.questionId;
    data['option'] = this.option;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
