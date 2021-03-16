import 'package:zapytaj/models/Category.dart';
import 'package:zapytaj/models/question.dart';
import 'package:zapytaj/models/tag.dart';
import 'package:zapytaj/services/ApiRepository.dart';
import 'package:flutter/material.dart';
import 'package:zapytaj/models/settings.dart';

class AppProvider with ChangeNotifier {
  Settings _settings;
  List<Category> _categories = [];
  List<Tag> _tags = [];
  List<Question> _recentQuestions = [];
  List<Question> _mostAnsweredQuestions = [];
  List<Question> _mostVisitedQuestions = [];
  List<Question> _mostVotedQuestions = [];
  List<Question> _noAnswersQuestions = [];
  List<Question> _favoriteQuestions = [];
  int _adClickCount = 0;

  Settings get settings {
    return _settings;
  }

  List<Category> get categories {
    return _categories;
  }

  List<Tag> get tags {
    return _tags;
  }

  List<Question> get recentQuestions {
    return _recentQuestions;
  }

  List<Question> get mostAnsweredQuestions {
    return _mostAnsweredQuestions;
  }

  List<Question> get mostVisitedQuestions {
    return _mostVisitedQuestions;
  }

  List<Question> get mostVotedQuestions {
    return _mostVotedQuestions;
  }

  List<Question> get noAnswersQuestions {
    return _noAnswersQuestions;
  }

  List<Question> get favoriteQuestions {
    return _favoriteQuestions;
  }

  int get adClickCount {
    return _adClickCount;
  }

  Future<bool> setSetting(Settings settings) async {
    _settings = settings;
    notifyListeners();
    return true;
  }

  Future<void> incrementAdClickCount() async {
    _adClickCount++;
    notifyListeners();
  }

  Future<void> resetAdClickCount() async {
    _adClickCount = 0;
    notifyListeners();
  }

  Future getSettings(BuildContext context) async {
    Settings settings = await ApiRepository.getSettings(context);
    if (settings != null) {
      this._settings = settings;
      notifyListeners();
    }
  }

  Future<bool> setCategories(List<Category> categories) async {
    _categories = categories;
    notifyListeners();
    return true;
  }

  Future getCategories(BuildContext context) async {
    List<Category> categories = await ApiRepository.getCategories(context);
    if (categories != null) {
      this._categories = categories;
      notifyListeners();
    }
  }

  Future getTags(BuildContext context) async {
    List<Tag> tags = await ApiRepository.getTags(context);
    if (tags != null) {
      this._tags = tags;
      notifyListeners();
    }
  }

  Future<bool> setRecentQuestions(List<Question> questions) async {
    this._recentQuestions = questions;
    notifyListeners();
    return true;
  }

  Future<bool> setMostAnsweredQuestions(List<Question> questions) async {
    _mostAnsweredQuestions = questions;
    notifyListeners();
    return true;
  }

  Future<bool> setMostVisitedQuestions(List<Question> questions) async {
    _mostVisitedQuestions = questions;
    notifyListeners();
    return true;
  }

  Future<bool> setMostVotedQuestions(List<Question> questions) async {
    _mostVotedQuestions = questions;
    notifyListeners();
    return true;
  }

  Future<bool> setNoAnswersQuestions(List<Question> questions) async {
    _noAnswersQuestions = questions;
    notifyListeners();
    return true;
  }

  Future<bool> setFavoriteQuestions(List<Question> questions) async {
    _favoriteQuestions = questions;
    notifyListeners();
    return true;
  }

  clearFavoriteQuestions() {
    _favoriteQuestions.clear();
    _favoriteQuestions = [];
  }

  clearRecentQuestions() {
    _recentQuestions = [];
  }

  clearMostAnsweredQuestions() {
    _mostAnsweredQuestions = [];
  }

  clearMostVisitedQuestions() {
    _mostVisitedQuestions = [];
  }

  clearMostVotedQuestions() {
    _mostVotedQuestions = [];
  }

  clearNoAnswersQuestions() {
    _noAnswersQuestions = [];
  }

  clearAllQuestions() {
    clearRecentQuestions();
    clearMostAnsweredQuestions();
    clearMostVisitedQuestions();
    clearMostVotedQuestions();
    clearNoAnswersQuestions();
    notifyListeners();
  }

  notifyListeners();
}
