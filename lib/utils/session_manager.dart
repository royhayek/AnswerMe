import 'dart:convert';

import 'package:zapytaj/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  final String firstTime = "firstime";
  final String loggedIn = "loggedIn";
  final String user = "user";
  final String password = "password";

  setFirstTime(bool state) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(this.firstTime, state);
  }

  Future<bool> getFirstTime() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    bool firsttime;
    firsttime = pref.getBool(this.firstTime) ?? true;
    return firsttime;
  }

  setLoggedIn(bool state) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(this.loggedIn, state);
  }

  Future<bool> getLoggedIn() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    bool loggedIn;
    loggedIn = pref.getBool(this.loggedIn) ?? false;
    return loggedIn;
  }

  Future setUser(User user) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String userJson = jsonEncode(user.toJson());
    pref.setString(this.user, userJson);
  }

  Future<User> getUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    Map userMap = jsonDecode(pref.getString(this.user));
    var user = User.fromJson(userMap);
    return user;
  }

  Future cleaUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove(this.user);
    await pref.remove(this.password);
    await pref.remove(this.loggedIn);
  }

  Future setPassword(String password) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(this.password, password);
  }

  Future<String> getPassword() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String password;
    password = pref.getString(this.password) ?? null;
    return password;
  }
}
