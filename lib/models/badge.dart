class Badge {
  int id;
  String name;
  String color;
  int from;
  int to;
  String description;

  Badge({this.id, this.name, this.color, this.from, this.to, this.description});

  Badge.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    color = json['color'];
    from = json['from'];
    to = json['to'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['color'] = this.color;
    data['from'] = this.from;
    data['to'] = this.to;
    data['description'] = this.description;
    return data;
  }
}
