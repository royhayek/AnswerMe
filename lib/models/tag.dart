class Tag {
  int id;
  String name;
  Null description;
  int parent;
  Null tanoxomy;
  Null termId;
  int status;
  String createdAt;
  String updatedAt;

  Tag(
      {this.id,
      this.name,
      this.description,
      this.parent,
      this.tanoxomy,
      this.termId,
      this.status,
      this.createdAt,
      this.updatedAt});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      parent: json['parent'],
      tanoxomy: json['tanoxomy'],
      termId: json['term_id'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['parent'] = this.parent;
    data['tanoxomy'] = this.tanoxomy;
    data['term_id'] = this.termId;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
