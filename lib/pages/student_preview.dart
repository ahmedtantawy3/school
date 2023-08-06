import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school/pages/edit_student.dart';
import 'package:school/services/my_group.dart';
import 'package:school/services/my_student.dart';
import 'package:calendar_view/calendar_view.dart';

class StudentPreview extends StatefulWidget {
  MyStudent myStudent;
  MyGroup? myGroup;
  StudentPreview({required this.myStudent, this.myGroup});

  @override
  _StudentPreviewState createState() => _StudentPreviewState();
}

class _StudentPreviewState extends State<StudentPreview> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _noteController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _addressController = TextEditingController();
  final firestoreInstance = FirebaseFirestore.instance;
  String groupName = '';
  List<MyGroup> allGroups = [];
  bool showGroupDifference = false;
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
    if (widget.myGroup != null) {
      if (widget.myGroup!.id != group.id) {
        showGroupDifference = true;
      } else {
        DocumentReference studentRef =
            firestoreInstance.collection('students').doc(widget.myStudent.id);

        const attendanceState = '2023,8,06,1';
        studentRef.set({
          'attendance': FieldValue.arrayUnion([attendanceState]),
        }, SetOptions(merge: true));

        widget.myStudent.attendance.add(attendanceState);
      }
    }
    setState(() {
      groupName = group.name;
      _nameController.text = widget.myStudent.name;
      _phoneController.text = widget.myStudent.phone;

      _parentPhoneController.text = widget.myStudent.parentPhone;

      _noteController.text = widget.myStudent.notes;
      _barcodeController.text = widget.myStudent.barcode;
      _addressController.text = widget.myStudent.location;
    });

    makeAttendance();
  }

  void makeAttendance() {
    final controller = CalendarControllerProvider.of(context).controller;
    controller.events.forEach((element) {
      controller.remove(element);
    });
    for (String attendance in widget.myStudent.attendance) {
      if (attendance.split(',').last == '1') {
        final attendanceComponents = attendance.split(',');
        attendanceComponents.removeLast();
        final event = CalendarEventData(
            date: DateTime(
                int.parse(attendanceComponents[0]),
                int.parse(attendanceComponents[1]),
                int.parse(attendanceComponents[2])),
            event: "Event 1",
            title: 'حضور',
            color: Colors.greenAccent);
        controller.add(event);
      } else if (attendance.split(',').last == '0') {
        final attendanceComponents = attendance.split(',');
        attendanceComponents.removeLast();
        final event2 = CalendarEventData(
            date: DateTime(
                int.parse(attendanceComponents[0]),
                int.parse(attendanceComponents[1]),
                int.parse(attendanceComponents[2])),
            event: "Event 1",
            title: 'حضور مخالف',
            color: Colors.yellow);
        controller.add(event2);
      }
    }
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
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        final MyStudent? myStudent = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditStudent(myStudent: widget.myStudent),
                          ),
                        );

                        if (myStudent != null) {
                          widget.myStudent = myStudent;
                          getFieldValue(myStudent.groupRef!);
                        }
                      },
                      child: const Text('تعديل'),
                    ),
                  ),
                ],
              ),
              if (showGroupDifference)
                Row(
                  children: [
                    const Text(
                      'هذا الطالب غير موجود فى المجموعة الحالية',
                      style: TextStyle(color: Colors.red),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll<Color>(Colors.pinkAccent),
                      ),
                      child: const Text(
                        'تسجيل حضور الطالب',
                      ),
                    ),
                  ],
                ),
              SizedBox(
                width: 300,
                height: 300,
                child: Image.memory(widget.myStudent.profileImage.bytes),
              ),
              TextFormField(
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ادخل الاسم';
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: 'الاسم'),
                enabled: false,
              ),
              TextFormField(
                controller: _phoneController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ادخل رقم الطالب';
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: 'رقم الطالب'),
                enabled: false,
              ),
              TextFormField(
                controller: _parentPhoneController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ادخل رقم ولى الامر';
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: 'رقم ولى الأمر'),
                enabled: false,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'العنوان'),
                enabled: false,
              ),
              TextFormField(
                controller: _noteController,
                maxLines: 5,
                decoration: const InputDecoration(
                    labelText: 'ملاحظات', alignLabelWithHint: true),
                enabled: false,
              ),
              TextFormField(
                controller: _barcodeController,
                decoration: const InputDecoration(labelText: 'كود الطالب'),
                enabled: false,
              ),
              Text(groupName),
              Container(
                width: 900,
                height: 800, // Set the height according to your needs.
                child: MonthView(
                  cellAspectRatio: 1.3,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
