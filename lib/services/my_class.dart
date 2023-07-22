import 'package:cloud_firestore/cloud_firestore.dart';

class MyClass {
  String id;
  String name;

  MyClass({required this.id, required this.name});

  factory MyClass.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    String id = doc.id;

    return MyClass(
      id: id,
      name: data['name'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'id': id,
      };
}
