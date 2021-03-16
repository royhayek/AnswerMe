import 'dart:convert';

import 'package:zapytaj/models/tag.dart';

QuestionTag questionTagFromJson(String str) =>
    QuestionTag.fromJson(json.decode(str));

String questionTagToJson(QuestionTag data) => json.encode(data.toJson());

class QuestionTag {
  int id;
  int questionId;
  String tag;
  Tag questionTag;

  QuestionTag({this.id, this.questionId, this.tag, this.questionTag});

  factory QuestionTag.fromJson(Map<String, dynamic> json) {
    return QuestionTag(
      id: json['id'],
      questionId: json['question_id'],
      tag: json['tag'],
      questionTag: json['question_tag'] != null
          ? Tag.fromJson(json['question_tag'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['question_id'] = this.questionId;
    data['tag'] = this.tag;
    if (this.questionTag != null) {
      data['question_tag'] = this.questionTag.toJson();
    }
    return data;
  }
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
