class Item {
  final int id;
  final String name;

  Item({required this.id, required this.name});

  factory Item.fromjson(Map<String, dynamic> json) {
    return Item(id: json['id'], name: json['name']);
  }
}
