import 'package:zapytaj/models/category.dart';
import 'package:zapytaj/models/question_data.dart';
import 'package:zapytaj/models/tag.dart';
import 'package:zapytaj/services/api_repository.dart';
import 'package:flutter/material.dart';
import 'package:zapytaj/models/settings.dart';

class AppProvider with ChangeNotifier {
  Settings _settings;
  List<Category> _categories = [];
  List<Tag> _tags = [];
  QuestionData _recentQuestions = QuestionData();

  Settings get settings {
    return _settings;
  }

  List<Category> get categories {
    return _categories;
  }

  List<Tag> get tags {
    return _tags;
  }

  QuestionData get recentQuestions {
    return _recentQuestions;
  }

  Future<bool> setSetting(Settings settings) async {
    _settings = settings;
    notifyListeners();
    return true;
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

  Future getRecentQuestions(BuildContext context, int offset, int page) async {
    QuestionData questions = await ApiRepository.getRecentQuestions(
        context, 'recentQuestions',
        offset: offset, page: page);
    if (categories != null) {
      this._recentQuestions = questions;
      notifyListeners();
    }
  }
}
