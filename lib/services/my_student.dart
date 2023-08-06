import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class MyStudent {
  String id;
  String name;
  String phone;
  String parentPhone;
  String notes;
  String barcode;
  String location;
  List<dynamic> attendance;

  Blob profileImage;
  DocumentReference? groupRef;

  MyStudent({
    required this.id,
    required this.name,
    required this.groupRef,
    required this.profileImage,
    required this.phone,
    required this.parentPhone,
    required this.notes,
    required this.barcode,
    required this.location,
    required this.attendance,
  });

  factory MyStudent.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    String id = doc.id;
    if (kIsWeb) {
      return MyStudent(
        id: id,
        name: data['name'] ?? '',
        groupRef: data['groupRef'],
        profileImage: data['profileImageUrl'] ?? '',
        notes: data['notes'] ?? '',
        parentPhone: data['parentPhone'] ?? '',
        phone: data['phone'] ?? '',
        barcode: data['barcode'] ?? '',
        location: data['address'] ?? '',
        attendance: data['attendance'] ?? [],
      );
    } else {
      return MyStudent(
        id: id,
        name: data['name'] ?? '',
        groupRef: data['groupRef'],
        profileImage:
            Blob(Uint8List.fromList(data['profileImageUrl'].cast<int>())),
        notes: data['notes'] ?? '',
        parentPhone: data['parentPhone'] ?? '',
        phone: data['phone'] ?? '',
        barcode: data['barcode'] ?? '',
        location: data['address'] ?? '',
        attendance: data['attendance'] ?? [],
      );
    }
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'groupRef': groupRef,
        'id': id,
        'profileImageUrl': profileImage,
        'parentPhone': parentPhone,
        'notes': notes,
        'phone': phone,
        'barcode': barcode,
        'address': location,
      };
}
