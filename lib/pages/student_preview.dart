import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school/services/my_group.dart';
import 'package:school/services/my_student.dart';

class StudentPreview extends StatefulWidget {
  final MyStudent myStudent;

  StudentPreview({required this.myStudent});

  @override
  _StudentPreviewState createState() => _StudentPreviewState();
}

class _StudentPreviewState extends State<StudentPreview> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _noteController = TextEditingController();

  final firestoreInstance = FirebaseFirestore.instance;
  String groupName = '';
  List<MyGroup> allGroups = [];
  @override
  void initState() {
    super.initState();
    if (widget.myStudent.groupRef != null) {
      getFieldValue(widget.myStudent.groupRef!);
    }
  }

  void getFieldValue(DocumentReference docRef) async {
    final snapShot = await docRef.get();
    final group = MyGroup.fromFirestore(snapShot);
    setState(() {
      groupName = group.name;
      _nameController.text = widget.myStudent.name;
      _phoneController.text = widget.myStudent.phone;

      _parentPhoneController.text = widget.myStudent.parentPhone;

      _noteController.text = widget.myStudent.notes;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.myStudent.name),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            SizedBox(
              width: 150,
              height: 150,
              child: Image.memory(widget.myStudent.profileImage.bytes),
            ),
            TextFormField(
              controller: _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              decoration: const InputDecoration(labelText: 'Name'),
              enabled: false,
            ),
            TextFormField(
              controller: _phoneController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a phone';
                }
                return null;
              },
              decoration: const InputDecoration(labelText: 'Phone'),
              enabled: false,
            ),
            TextFormField(
              controller: _parentPhoneController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a parent phone';
                }
                return null;
              },
              decoration: const InputDecoration(labelText: 'Parent Phone'),
              enabled: false,
            ),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Notes'),
              enabled: false,
            ),
            Text(groupName),
          ],
        ),
      ),
    );
  }
}
