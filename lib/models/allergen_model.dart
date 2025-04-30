class AllergenModel {
  final String name;

  AllergenModel({required this.name});

  Map<String, dynamic> toMap() {
    return {'name': name};
  }

  factory AllergenModel.fromMap(Map<String, dynamic> map) {
    return AllergenModel(name: map['name']);
  }
}