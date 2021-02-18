import 'dart:convert';
import 'package:zapytaj/models/question.dart';

QuestionData questionDataFromJson(String str) =>
    QuestionData.fromJson(json.decode(str));

String questionDataToJson(QuestionData data) => json.encode(data.toJson());

class QuestionData {
  int currentPage;
  List<Question> data;
  String firstPageUrl;
  int from;
  int lastPage;
  String lastPageUrl;
  String nextPageUrl;

  QuestionData({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.nextPageUrl,
  });

  factory QuestionData.fromJson(Map<String, dynamic> json) {
    return QuestionData(
      currentPage: json["current_page"],
      data: json["data"] != null
          ? List<Question>.from(json["data"].map((x) => Question.fromJson(x)))
          : null,
      firstPageUrl: json["first_page_url"],
      from: json["from"],
      lastPage: json["last_page"],
      lastPageUrl: json["last_page_url"],
      nextPageUrl: json["next_page_url"],
    );
  }

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "first_page_url": firstPageUrl,
        "from": from,
        "last_page": lastPage,
        "last_page_url": lastPageUrl,
        "next_page_url": nextPageUrl,
      };
}

class Link {
  String url;
  String label;
  bool active;

  Link({this.url, this.label, this.active});

  Link.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    label = json['label'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['label'] = this.label;
    data['active'] = this.active;
    return data;
  }
}
