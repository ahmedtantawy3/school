import 'package:cloud_firestore/cloud_firestore.dart';

class MyGroup {
  String id;
  String name;
  DocumentReference? reference;
  MyGroup({required this.id, required this.name, required this.reference});

  factory MyGroup.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String id = doc.id;

    return MyGroup(id: id, name: data['name'] ?? '', reference: doc.reference);
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'id': id,
      };
}
