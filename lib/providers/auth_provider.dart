import 'package:toast/toast.dart';
import 'package:zapytaj/models/question.dart';
import 'package:zapytaj/models/user.dart';
import 'package:zapytaj/services/api_repository.dart';
import 'package:zapytaj/utils/session_manager.dart';
import 'package:flutter/widgets.dart';

class AuthProvider with ChangeNotifier {
  User _user = User();
  List<Question> _questions = [];
  List<Question> _polls = [];
  List<Question> _favorites = [];
  List<Question> _asked = [];
  List<Question> _waiting = [];

  User get user => _user;

  List<Question> get questions => _questions;
  List<Question> get polls => _polls;
  List<Question> get favorites => _favorites;
  List<Question> get asked => _asked;
  List<Question> get waiting => _waiting;

  Future setQuestions(List<Question> value) async {
    this._questions = value;
    notifyListeners();
  }

  Future setPolls(List<Question> value) async {
    this._polls = value;
    notifyListeners();
  }

  Future setFavorites(List<Question> value) async {
    this._favorites = value;
    notifyListeners();
  }

  Future setAsked(List<Question> value) async {
    this._asked = value;
    notifyListeners();
  }

  Future setWaiting(List<Question> value) async {
    this._waiting = value;
    notifyListeners();
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
      await prefs.setUser(user);
      this._user = user;
      notifyListeners();
    }
  }

  clearProfileQuestions() {
    this._questions.clear();
    this._polls.clear();
    this._favorites.clear();
    this._asked.clear();
    this._waiting.clear();
    notifyListeners();
  }
}
