import 'dart:convert';
import 'dart:io';

import 'package:zapytaj/models/badge.dart';
import 'package:zapytaj/models/category.dart';
import 'package:zapytaj/config/app_config.dart';
import 'package:zapytaj/models/comment.dart';
import 'package:zapytaj/models/point.dart';
import 'package:zapytaj/models/question.dart';
import 'package:zapytaj/models/question_data.dart';
import 'package:zapytaj/models/result_option.dart';
import 'package:zapytaj/models/settings.dart';
import 'package:zapytaj/models/tag.dart';
import 'package:zapytaj/models/user.dart';
import 'package:zapytaj/providers/app_provider.dart';
import 'package:zapytaj/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:zapytaj/screens/other/askQuestion.dart';
import 'package:zapytaj/services/request_helper.dart';

class ApiRepository {
  // API URL (The file performing CRUD operations)
  static const API = URL + '/api';

  // Images paths in the server
  static const AVATAR_IMAGES_PATH = URL + '/uploads/users/avatars/';
  static const COVER_IMAGES_PATH = URL + '/uploads/users/covers/';
  static const OPTION_IMAGES_PATH = URL + '/uploads/optionimages/';
  static const FEATURED_IMAGES_PATH = URL + '/uploads/featuredImages/';

  static const headers = {"Accept": "application/json"};

  static Future<User> registerUser(BuildContext context, String username,
      String email, String password) async {
    Map<String, dynamic> data = {
      "username": username,
      "email": email,
      "password": password,
    };
    http.Response response =
        await RequestHelper.post(context, endpoint: '/users', data: data);
    if (201 == response.statusCode) {
      final parsed = json.decode(response.body);
      User user = User.fromJson(parsed);
      return user;
    } else if (400 == response.statusCode) {
      final parsed = json.decode(response.body).cast<String, dynamic>();
      if (parsed["username"] != null)
        Toast.show(parsed["username"][0], context, duration: 2);
      else if (parsed["email"] != null)
        Toast.show(parsed["email"][0], context, duration: 2);
      else if (parsed['password'] != null)
        Toast.show(parsed['password'][0], context, duration: 2);
      return null;
    } else {
      return null;
    }
  }

  static Future<User> loginUser(BuildContext context,
      {String username, String password}) async {
    http.Response response;
    try {
      Map<String, dynamic> emaildata = {
        "email": username,
        "password": password,
      };
      Map<String, dynamic> usernamedata = {
        "username": username,
        "password": password,
      };

      if (username.contains('@'))
        response = await RequestHelper.post(context,
            endpoint: '/login', data: emaildata);
      else
        response = await RequestHelper.post(context,
            endpoint: '/login', data: usernamedata);

      final parsed = json.decode(response.body);
      User user = User.fromJson(parsed['user']);
      if (user != null) {
        AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);
        await auth.setUser(user);
      }
      return user;
    } catch (e) {
      print(e);
      print(response.body);
      return User();
    }
  }

  static Future<User> getUserInfo(BuildContext context, {int userId}) async {
    http.Response response = await RequestHelper.get(
      context,
      endpoint: '/getUserInfo/$userId',
    );
    final parsed = json.decode(response.body);
    User user = User.fromJson(parsed);
    return user;
  }

  static Future<User> getUserProfile(BuildContext context, {int userId}) async {
    http.Response response = await RequestHelper.get(
      context,
      endpoint: '/getUserProfile/$userId',
    );
    final parsed = json.decode(response.body);
    User user = User.fromJson(parsed);
    return user;
  }

  static Future<Settings> getSettings(BuildContext context) async {
    http.Response response = await RequestHelper.get(
      context,
      endpoint: '/settings',
    );
    final parsed = json.decode(response.body);
    Settings settings = Settings.fromJson(parsed);
    if (settings != null) {
      print('Retrieved Settings');
      return settings;
    }
    return null;
  }

  static Future<List<Question>> getProfileQuestions(
      BuildContext context, String endpoint, int id) async {
    http.Response response = await RequestHelper.get(
      context,
      endpoint: '/$endpoint/$id',
    );
    final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Question> questions =
        parsed.map<Question>((json) => Question.fromJson(json)).toList();
    if (questions != null) {
      print('Retrieved User questions');
      return questions;
    }
    return null;
  }

  static Future<List<Question>> getUserPollQuestions(BuildContext context,
      {int id}) async {
    http.Response response = await RequestHelper.get(
      context,
      endpoint: '/getUserPollQuestions/$id',
    );
    final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Question> questions =
        parsed.map<Question>((json) => Question.fromJson(json)).toList();
    if (questions != null) {
      print('Retrieved User poll questions');
      return questions;
    }
    return null;
  }

  static Future<List<Question>> getUserFavQuestions(BuildContext context,
      {int id}) async {
    http.Response response = await RequestHelper.get(
      context,
      endpoint: '/getUserFavQuestions/$id',
    );
    final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Question> questions =
        parsed.map<Question>((json) => Question.fromJson(json)).toList();
    if (questions != null) {
      print('Retrieved User favorite questions');
      return questions;
    }
    return null;
  }

  static Future<List<Category>> getCategories(BuildContext context) async {
    http.Response response = await RequestHelper.get(
      context,
      endpoint: '/categories',
    );
    final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Category> categories =
        parsed.map<Category>((json) => Category.fromJson(json)).toList();
    if (categories != null) {
      print('Retrieved Categories');
      return categories;
    }
    return null;
  }

  static Future<List<Tag>> getTags(BuildContext context) async {
    http.Response response = await RequestHelper.get(
      context,
      endpoint: '/tags',
    );
    final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Tag> tags = parsed.map<Tag>((json) => Tag.fromJson(json)).toList();
    if (tags != null) {
      return tags;
    }
    return null;
  }

  static Future<User> updateProfile(BuildContext context,
      {int userId,
      File avatar,
      String avatarname,
      File cover,
      String covername,
      String displayname,
      String email,
      String bio,
      String password}) async {
    List<http.MultipartFile> files = [];
    if (avatar != null) {
      files.add(
        http.MultipartFile(
          'avatar',
          avatar.readAsBytes().asStream(),
          avatar.lengthSync(),
          filename: avatarname,
        ),
      );
    }
    if (cover != null) {
      files.add(
        http.MultipartFile(
          'cover',
          cover.readAsBytes().asStream(),
          cover.lengthSync(),
          filename: covername,
        ),
      );
    }

    Map<String, String> data = {
      'displayname': displayname,
      'email': email,
      'description': bio,
      'password': password != null ? password : null
    };

    String resBody = await RequestHelper.multipartRequest(
      context,
      endpoint: '/users/$userId?_method=PUT',
      data: data,
      files: files,
    );

    final responseJson = json.decode(resBody);
    User user = User.fromJson(responseJson);
    AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.setUser(user);
    if (resBody.contains('message')) {
      Toast.show(responseJson['message'], context);
    }
    return user;
  }

  static Future addQuestion(BuildContext context,
      {Question question,
      List<String> tags,
      List<String> options,
      File featuredImage,
      String featuredImageName,
      List<Option> imageOptions}) async {
    List<http.MultipartFile> files = [];

    if (featuredImage != null) {
      files.add(
        http.MultipartFile(
          'featuredImage',
          featuredImage.readAsBytes().asStream(),
          featuredImage.lengthSync(),
          filename: featuredImageName,
        ),
      );
    }

    Map<String, String> data = {
      "title": question.title != null ? question.title : null,
      "titlePlain": question.titlePlain != null ? question.titlePlain : '',
      "content": question.content != null ? question.content : null,
      "videoURL": question.videoURL != '' ? question.videoURL : '',
      "polled": question.polled != null ? question.polled.toString() : '',
      "pollTitle": question.pollTitle != null ? question.pollTitle : '',
      "imagePolled":
          question.imagePolled != null ? question.imagePolled.toString() : '',
      "created_at": question.createdAt != null ? question.createdAt : null,
      "author_id":
          question.authorId != null ? question.authorId.toString() : null,
      "category_id":
          question.categoryId != null ? question.categoryId.toString() : '',
      "tag": tags != null ? json.encode(tags) : '',
      "option": options != null ? json.encode(options) : '',
      "asking": question.asking != null ? question.asking.toString() : '',
    };

    String resBody = await RequestHelper.multipartRequest(
      context,
      endpoint: '/addQuestion',
      data: data,
      files: files,
    );
    final responseJson = json.decode(resBody);
    if (resBody.contains('message')) {
      Toast.show(responseJson['message'], context);
    }

    if (responseJson['id'] != null) {
      if (imageOptions.isNotEmpty || options.isNotEmpty) {
        addImageOptions(context, responseJson['id'], imageOptions, options);
      }
    }
  }

  static addImageOptions(BuildContext context, int questionId,
      List<Option> imageOptions, List<String> options) {
    if (imageOptions.length != 0) {
      imageOptions.where((o) => o != null).forEach((option) async {
        if (option != null) {
          List<http.MultipartFile> files = [];
          files.add(
            http.MultipartFile(
              'image',
              option.image.readAsBytes().asStream(),
              option.image.lengthSync(),
              filename: option.image.path.split('/').last,
            ),
          );

          Map<String, String> data = {
            "question_id": questionId != null ? questionId.toString() : null,
            "option": option.option != null ? option.option : '',
          };

          String resBody = await RequestHelper.multipartRequest(
            context,
            endpoint: '/addQuestionOptions',
            data: data,
            files: files,
          );

          final responseJson = json.decode(resBody);
          if (resBody.contains('message')) {
            Toast.show(responseJson['message'], context);
          }
        }
      });
    } else if (options.isNotEmpty) {
      options.where((o) => o.isNotEmpty).forEach((option) async {
        Map<String, String> data = {
          "question_id": questionId != null ? questionId.toString() : null,
          "option": option != null ? option : '',
        };

        http.Response resBody = await RequestHelper.post(
          context,
          endpoint: '/addQuestionOptions',
          data: data,
        );

        final responseJson = json.decode(resBody.body);
        if (responseJson['message'] != null) {
          Toast.show(responseJson['message'], context);
        }
      });
    }
  }

  static Future addComment(
    BuildContext context,
    Comment comment,
    File featuredImage,
    String featuredImageName,
  ) async {
    List<http.MultipartFile> files = [];

    if (featuredImage != null) {
      files.add(
        http.MultipartFile(
          'featuredImage',
          featuredImage.readAsBytes().asStream(),
          featuredImage.lengthSync(),
          filename: featuredImageName,
        ),
      );
    }

    Map<String, String> data = {
      "type": comment.type,
      "content": comment.content,
      "author_id": comment.authorId.toString(),
      "question_id": comment.questionId.toString(),
      "answer_id": comment.answerId != null ? comment.answerId.toString() : '',
    };

    String resBody = await RequestHelper.multipartRequest(
      context,
      endpoint: '/addComment',
      data: data,
      files: files,
    );
    final responseJson = json.decode(resBody);
    if (resBody.contains('message')) {
      Toast.show(responseJson['message'], context);
    }
  }

  static Future<Question> getQuestion(
      BuildContext context, int questionId, int userId) async {
    http.Response response = await RequestHelper.get(
      context,
      endpoint: '/getQuestion/$questionId/$userId',
    );
    final responseJson = json.decode(response.body);
    Question question = Question.fromJson(responseJson);
    return question;
  }

  static Future<QuestionData> getRecentQuestions(
      BuildContext context, String endpoint,
      {int offset, int page, int userId}) async {
    http.Response response;
    response = await RequestHelper.get(
      context,
      endpoint: '/$endpoint/$userId/$offset?page=$page',
    );
    QuestionData pagesData = questionDataFromJson(response.body);
    return pagesData;
  }

  static Future<QuestionData> getQuestionsByCategory(
      BuildContext context, int catId,
      {int offset, int page, int userId}) async {
    http.Response response = await RequestHelper.get(context,
        endpoint: '/getQuestionByCategory/$catId/$userId/$offset?page=$page');
    QuestionData pagesData = questionDataFromJson(response.body);
    return pagesData;
  }

  static Future<List<String>> getQuestionPollOptions(
      BuildContext context, int questionId) async {
    http.Response response = await RequestHelper.get(
      context,
      endpoint: '/getQuestionPollOptions/$questionId',
    );
    List<String> options = json.decode(response.body);
    return options;
  }

  static Future forgotPassword(BuildContext context, String email) async {
    Map<String, dynamic> data = {"email": email};
    await RequestHelper.post(context, endpoint: '/forgotPassword', data: data);
  }

  static Future followCategory(
      BuildContext context, int userId, int categoryId) async {
    Map<String, dynamic> data = {
      "user_id": userId.toString(),
      "category_id": categoryId.toString(),
    };
    await RequestHelper.post(context, endpoint: '/followCategory', data: data);
  }

  static Future setAsBestAnswer(BuildContext context,
      {int questionId, int answerId}) async {
    Map<String, dynamic> data = {
      "question_id": questionId.toString(),
      "answer_id": answerId.toString(),
    };
    await RequestHelper.post(context, endpoint: '/setAsBestAnswer', data: data);
  }

  static Future<List<Question>> searchQuestions(BuildContext context,
      {String title}) async {
    http.Response response = await RequestHelper.get(
      context,
      endpoint: '/question/search/$title',
    );
    final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Question> categories =
        parsed.map<Question>((json) => Question.fromJson(json)).toList();
    return categories;
  }

  static Future submitReport(BuildContext context,
      {int userId,
      int questionId,
      int answerId,
      String content,
      String type}) async {
    Map<String, dynamic> data = {
      "author_id": userId != null ? userId.toString() : 0,
      "question_id": questionId.toString(),
      "answer_id": answerId != null ? answerId.toString() : '',
      "content": content.toString(),
      "type": type.toString(),
    };
    await RequestHelper.post(context, endpoint: '/reports', data: data);
  }

  // voteQuestion
  static Future voteQuestion(
    BuildContext context, {
    int userId,
    int questionId,
    int vote,
  }) async {
    Map<String, dynamic> data = {
      "user_id": userId.toString(),
      "question_id": questionId.toString(),
      "vote": vote.toString(),
    };
    await RequestHelper.post(context, endpoint: '/voteQuestion', data: data);
  }

  static Future submitOption(BuildContext context,
      {int userId, int questionId, int optionId}) async {
    Map<String, dynamic> data = {
      "user_id": userId.toString(),
      "question_id": questionId.toString(),
      "option_id": optionId.toString(),
    };
    await RequestHelper.post(context, endpoint: '/submitOption', data: data);
  }

  static Future sendMessage(BuildContext context,
      {String name, String email, String message}) async {
    Map<String, dynamic> data = {
      "name": name,
      "email": email,
      "message": message,
      "created_at": DateTime.now().toString(),
    };
    await RequestHelper.post(context, endpoint: '/messages', data: data);
  }

  static Future voteComment(BuildContext context,
      {int userId, int commentId, int vote}) async {
    Map<String, dynamic> data = {
      "user_id": userId.toString(),
      "comment_id": commentId.toString(),
      "vote": vote.toString(),
    };
    await RequestHelper.post(context, endpoint: '/voteComment', data: data);
  }

  static Future<int> getQuestionVotes(BuildContext context,
      {int questionId}) async {
    http.Response response = await RequestHelper.get(
      context,
      endpoint: '/getQuestionVotes/$questionId',
    );
    return json.decode(response.body);
  }

  static Future<int> checkIfOptionSelected(BuildContext context,
      {int questionId, int userId}) async {
    Map<String, dynamic> data = {
      "question_id": questionId.toString(),
      "user_id": userId.toString(),
    };
    http.Response response = await RequestHelper.post(
      context,
      endpoint: '/checkIfOptionSelected',
      data: data,
    );
    final parsed = json.decode(response.body);
    return parsed['option_id'];
  }

  static Future<ResultOption> displayVoteResult(BuildContext context,
      {int questionId, int userId}) async {
    Map<String, dynamic> data = {
      "question_id": questionId.toString(),
      "user_id": userId.toString(),
    };
    http.Response response = await RequestHelper.post(
      context,
      endpoint: '/displayVoteResult',
      data: data,
    );
    final responseJson = json.decode(response.body);
    ResultOption question = ResultOption.fromJson(responseJson);
    return question;
  }

  static Future<int> getCommentVotes(BuildContext context,
      {int commentId}) async {
    http.Response response = await RequestHelper.get(
      context,
      endpoint: '/getCommentVotes/$commentId',
    );
    return json.decode(response.body);
  }

  static Future updateQuestionViews(BuildContext context,
      {int questionId}) async {
    await RequestHelper.put(
      context,
      endpoint: '/updateQuestionViews/$questionId',
    );
  }

  static Future addToFavorites(BuildContext context,
      {int questionId, int userId}) async {
    Map<String, dynamic> data = {
      "user_id": userId.toString(),
      "question_id": questionId.toString(),
    };
    await RequestHelper.post(context, endpoint: '/addToFavorites', data: data);
  }

  static Future<QuestionData> getFavoriteQuestions(BuildContext context,
      {int userId, int offset, int page}) async {
    http.Response response = await RequestHelper.get(
      context,
      endpoint: '/getUserFavorites/$userId/$offset?page=$page',
    );
    QuestionData pagesData = questionDataFromJson(response.body);
    return pagesData;
  }

  static Future<bool> followOrUnfollowUser(BuildContext context,
      {int followerId, int userId}) async {
    http.Response response = await RequestHelper.post(
      context,
      endpoint: '/addUserFollow/$userId/$followerId',
    );
    final parsed = json.decode(response.body);
    return parsed['following'];
  }

  static Future<bool> checkIfIsFavorite(BuildContext context,
      {int userId, int questionId}) async {
    http.Response response = await RequestHelper.get(
      context,
      endpoint: '/checkIfIsFavorite/$userId/$questionId',
    );
    final parsed = json.decode(response.body);
    return parsed['favorite'];
  }

  static Future<List<User>> getUserFollowing(BuildContext context,
      {int userId}) async {
    http.Response response = await RequestHelper.get(
      context,
      endpoint: '/getUserFollowing/$userId',
    );
    final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
    List<User> users = parsed.map<User>((json) => User.fromJson(json)).toList();
    return users;
  }

  static Future<List<User>> getUserFollowers(BuildContext context,
      {int userId}) async {
    http.Response response = await RequestHelper.get(
      context,
      endpoint: '/getUserFollowers/$userId',
    );
    final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
    List<User> users = parsed.map<User>((json) => User.fromJson(json)).toList();
    return users;
  }

  static Future<bool> checkIfIsFollowing(BuildContext context,
      {int userId, int followerId}) async {
    http.Response response = await RequestHelper.get(
      context,
      endpoint: '/checkIfUserIsFollowing/$userId/$followerId',
    );
    final parsed = json.decode(response.body);
    return parsed['following'];
  }

  static Future<List<Point>> getPoints(BuildContext context) async {
    http.Response response = await RequestHelper.get(
      context,
      endpoint: '/points',
    );
    final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Point> points =
        parsed.map<Point>((json) => Point.fromJson(json)).toList();
    return points;
  }

  static Future<List<Badge>> getBadges(BuildContext context) async {
    http.Response response = await RequestHelper.get(
      context,
      endpoint: '/badges',
    );
    final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Badge> badges =
        parsed.map<Badge>((json) => Badge.fromJson(json)).toList();
    return badges;
  }
}
