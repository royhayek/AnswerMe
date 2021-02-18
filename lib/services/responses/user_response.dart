import 'package:zapytaj/models/user_details.dart';

class UserResponse {
  bool status;
  String success;
  int statusCode;
  String message;
  String error;
  String token;
  UserDetails user;

  UserResponse({this.status, this.user});

  UserResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    user = json['user'] != null ? new UserDetails.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    return data;
  }
}
