import 'package:zapytaj/models/follower.dart';

class Category {
  int id;
  String name;
  String description;
  int parent;
  int termId;
  String taxonomy;
  int categoryFollowers;
  bool followed;
  List<Follower> followers;

  Category({
    this.id,
    this.name,
    this.description,
    this.parent,
    this.termId,
    this.taxonomy,
    this.categoryFollowers,
    this.followed,
    this.followers,
  });

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    parent = json['parent'];
    termId = json['term_id'];
    taxonomy = json['taxonomy'];
    // categoryFollowers = json['category_followers'];
    // followed = json['followed'];
    followers = json["followers"] != null
        ? List<Follower>.from(
            json["followers"].map((x) => Follower.fromJson(x)))
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['parent'] = this.parent;
    data['term_id'] = this.termId;
    data['taxonomy'] = this.taxonomy;
    // data['category_followers'] = this.categoryFollowers;
    // data['followed'] = this.followed;
    data['followers'] = this.followers;
    return data;
  }
}
