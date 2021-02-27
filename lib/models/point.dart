class Point {
  int id;
  int points;
  String description;

  Point({this.id, this.points, this.description});

  Point.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    points = json['points'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['points'] = this.points;
    data['description'] = this.description;
    return data;
  }
}
