import 'package:toast/toast.dart';
import 'package:zapytaj/models/user.dart';
import 'package:zapytaj/services/api_repository.dart';
import 'package:zapytaj/utils/session_manager.dart';
import 'package:flutter/widgets.dart';

class AuthProvider with ChangeNotifier {
  User _user = User();

  User get user {
    return _user;
  }

  Future<bool> setUser(User user) async {
    this._user = user;
    notifyListeners();
    return true;
  }

  Future clearUser() async {
    this._user = null;
    notifyListeners();
  }

  Future<User> loginUser(
      BuildContext context, String username, String password) async {
    SessionManager prefs = SessionManager();
    User user = await ApiRepository.loginUser(context,
        username: username, password: password);
    if (user != null) {
      if (user.emailVerifiedAt != null) {
        await prefs.setLoggedIn(true);
        await prefs.setPassword(password);
        await prefs.setUser(user);
      } else {
        Toast.show(
          'Please check your inbox and verify your email.',
          context,
          duration: 2,
        );
        return null;
      }
    }
    return user;
  }

  Future getUserInfo(BuildContext context, int userId) async {
    SessionManager prefs = SessionManager();
    User user = await ApiRepository.getUserInfo(context, userId: userId);
    if (user != null) {
      print(user.displayname);
      await prefs.setUser(user);
      this._user = user;
      notifyListeners();
    }
  }
}
