import 'package:zapytaj/models/option.dart';

class ResultOption {
  List<Option> options;
  int votesCount;

  ResultOption({this.options, this.votesCount});

  ResultOption.fromJson(Map<String, dynamic> json) {
    if (json['options'] != null) {
      options = new List<Option>();
      json['options'].forEach((v) {
        options.add(new Option.fromJson(v));
      });
    }
    votesCount = json['votesCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.options != null) {
      data['options'] = this.options.map((v) => v.toJson()).toList();
    }
    data['votesCount'] = this.votesCount;
    return data;
  }
}
