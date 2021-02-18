class Badge {
  String name;
  String color;

  Badge({this.name, this.color});

  Badge.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    color = json['color'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['color'] = this.color;
    return data;
  }
}
