import 'Badge.dart';

class User {
  int id;
  String username;
  String nicename;
  String email;
  String url;
  String registered;
  String displayname;
  String firstname;
  String lastname;
  String nickname;
  String description;
  String capabilities;
  String userGroup;
  String avatar;
  String cover;
  int points;
  int followers;
  int following;
  List<User> userFollowers;
  int questions;
  int answers;
  int bestAnswers;
  int posts;
  int comments;
  int notifications;
  int newNotifications;
  int verified;
  Badge badge;
  String profileCredential;
  int admin;
  String emailVerifiedAt;
  String createdAt;
  String updatedAt;

  User(
      {this.id,
      this.username,
      this.nicename,
      this.email,
      this.url,
      this.registered,
      this.displayname,
      this.firstname,
      this.lastname,
      this.nickname,
      this.description,
      this.capabilities,
      this.userGroup,
      this.avatar,
      this.cover,
      this.points,
      this.followers,
      this.following,
      this.userFollowers,
      this.questions,
      this.answers,
      this.bestAnswers,
      this.posts,
      this.comments,
      this.notifications,
      this.newNotifications,
      this.verified,
      this.badge,
      this.profileCredential,
      this.admin,
      this.emailVerifiedAt,
      this.createdAt,
      this.updatedAt});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    nicename = json['nicename'];
    email = json['email'];
    url = json['url'];
    registered = json['registered'];
    displayname = json['displayname'];
    firstname = json['firstname'];
    lastname = json['lastname'];
    nickname = json['nickname'];
    description = json['description'];
    capabilities = json['capabilities'];
    userGroup = json['user_group'];
    avatar = json['avatar'];
    cover = json['cover'];
    points = json['points'];
    followers = json['followers'];
    following = json['following'];
    if (json['user_followers'] != null) {
      userFollowers = [];
      json['user_followers'].forEach((v) {
        userFollowers.add(new User.fromJson(v));
      });
    }
    questions = json['questions'];
    answers = json['answers'];
    bestAnswers = json['best_answers'];
    posts = json['posts'];
    comments = json['comments'];
    notifications = json['notifications'];
    newNotifications = json['new_notifications'];
    verified = json['verified'];
    badge = json['badge'] != null ? new Badge.fromJson(json['badge']) : null;
    profileCredential = json['profile_credential'];
    admin = json['admin'];
    emailVerifiedAt = json['email_verified_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    data['nicename'] = this.nicename;
    data['email'] = this.email;
    data['url'] = this.url;
    data['registered'] = this.registered;
    data['displayname'] = this.displayname;
    data['firstname'] = this.firstname;
    data['lastname'] = this.lastname;
    data['nickname'] = this.nickname;
    data['description'] = this.description;
    data['capabilities'] = this.capabilities;
    data['user_group'] = this.userGroup;
    data['avatar'] = this.avatar;
    data['cover'] = this.cover;
    data['points'] = this.points;
    data['followers'] = this.followers;
    data['following'] = this.following;
    if (this.userFollowers != null) {
      data['user_followers'] =
          this.userFollowers.map((v) => v.toJson()).toList();
    }
    data['questions'] = this.questions;
    data['answers'] = this.answers;
    data['best_answers'] = this.bestAnswers;
    data['posts'] = this.posts;
    data['comments'] = this.comments;
    data['notifications'] = this.notifications;
    data['new_notifications'] = this.newNotifications;
    data['verified'] = this.verified;
    if (this.badge != null) {
      data['badge'] = this.badge.toJson();
    }
    data['profile_credential'] = this.profileCredential;
    data['admin'] = this.admin;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
