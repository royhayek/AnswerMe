import 'package:zapytaj/models/badge.dart';
import 'package:zapytaj/models/user.dart';

class UserDetails {
  int id;
  String displayname;
  String firstname;
  String lastname;
  String nickname;
  String description;
  String registered;
  String email;
  String avatar;
  String cover;
  int points;
  int followers;
  int questions;
  int answers;
  int bestAnswers;
  int notifications;
  int newNotifications;
  List<User> userFollowers;
  bool verified;
  bool followed;
  Badge badge;

  UserDetails({
    this.id,
    this.displayname,
    this.firstname,
    this.lastname,
    this.nickname,
    this.description,
    this.registered,
    this.email,
    this.avatar,
    this.cover,
    this.points,
    this.followers,
    this.questions,
    this.answers,
    this.bestAnswers,
    this.notifications,
    this.newNotifications,
    this.userFollowers,
    this.verified,
    this.followed,
    this.badge,
  });

  UserDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    displayname = json['displayname'];
    firstname = json['firstname'];
    lastname = json['lastname'];
    nickname = json['nickname'];
    description = json['description'];
    registered = json['registered'];
    email = json['email'];
    avatar = json['avatar'];
    cover = json['cover'];
    points = json['points'];
    followers = json['followers'];
    questions = json['questions'];
    answers = json['answers'];
    bestAnswers = json['best_answers'];
    notifications = json['notifications'];
    newNotifications = json['new_notifications'];
    if (json['user_followers'] != null) {
      userFollowers = new List<User>();
      json['user_followers'].forEach((v) {
        userFollowers.add(new User.fromJson(v));
      });
    }
    verified = json['verified'];
    followed = json['followed'];
    badge = json['badge'] != null ? new Badge.fromJson(json['badge']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['displayname'] = this.displayname;
    data['firstname'] = this.firstname;
    data['lastname'] = this.lastname;
    data['nickname'] = this.nickname;
    data['description'] = this.description;
    data['registered'] = this.registered;
    data['email'] = this.email;
    data['avatar'] = this.avatar;
    data['cover'] = this.cover;
    data['points'] = this.points;
    data['followers'] = this.followers;
    data['questions'] = this.questions;
    data['answers'] = this.answers;
    data['best_answers'] = this.bestAnswers;
    data['notifications'] = this.notifications;
    data['new_notifications'] = this.newNotifications;
    if (this.userFollowers != null) {
      data['user_followers'] =
          this.userFollowers.map((v) => v.toJson()).toList();
    }
    data['verified'] = this.verified;
    data['followed'] = this.followed;
    if (this.badge != null) {
      data['badge'] = this.badge.toJson();
    }
    return data;
  }
}
