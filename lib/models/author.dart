import 'badge.dart';

class Author {
  int id;
  String slug;
  String name;
  String firstName;
  String lastName;
  String nickname;
  String url;
  String description;
  String avatar;
  bool verified;
  Badge badge;
  String profileCredential;
  bool followed;

  Author(
      {this.id,
      this.slug,
      this.name,
      this.firstName,
      this.lastName,
      this.nickname,
      this.url,
      this.description,
      this.avatar,
      this.verified,
      this.badge,
      this.profileCredential,
      this.followed});

  Author.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    slug = json['slug'];
    name = json['name'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    nickname = json['nickname'];
    url = json['url'];
    description = json['description'];
    avatar = json['avatar'];
    verified = json['verified'];
    badge = json['badge'] != null ? new Badge.fromJson(json['badge']) : null;
    profileCredential = json['profile_credential'];
    followed = json['followed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['slug'] = this.slug;
    data['name'] = this.name;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['nickname'] = this.nickname;
    data['url'] = this.url;
    data['description'] = this.description;
    data['avatar'] = this.avatar;
    data['verified'] = this.verified;
    if (this.badge != null) {
      data['badge'] = this.badge.toJson();
    }
    data['profile_credential'] = this.profileCredential;
    data['followed'] = this.followed;
    return data;
  }
}
