import 'dart:developer';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school/bloc/GroupList/bloc/group_list_bloc.dart';
import 'package:school/pages/edit_student.dart';
import 'package:school/services/my_group.dart';
import 'package:school/services/my_student.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../bloc/StudentsList/students_list_bloc.dart';

class StudentPreview extends StatefulWidget {
  MyStudent myStudent;
  MyGroup? myGroup;
  List<MyGroup> allGroups;

  StudentPreview({
    required this.myStudent,
    this.myGroup,
    List<MyGroup>? allGroups,
  }) : allGroups = allGroups ?? [];
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

  String _formattedDate = '2023,07,11';
  String groupName = '';
  bool showGroupDifference = false;
  late bool visible;
  @override
  void initState() {
    super.initState();

    final DateTime now = DateTime.now();
    final String formattedDate =
        '${now.year},${now.month.toString().padLeft(2, '0')},${now.day.toString().padLeft(2, '0')}';
    print(formattedDate);
    _formattedDate = formattedDate;
    if (widget.myStudent.groupRef != null) {
      getFieldValue(widget.myStudent.groupRef!);
    }
  }

  void getFieldValue(DocumentReference docRef) async {
    List<MyGroup> groups = [];
    try {
      groups =
          BlocProvider.of<GroupListBloc>(context, listen: false).state.groups;
    } catch (_) {
      final snapShot = await docRef.get();
      groups = [MyGroup.fromFirestore(snapShot)];
    }

    final MyGroup? group = groups.where((element) {
      // ignore: avoid_print
      print(element.id + docRef.id);
      return element.id == docRef.id;
    }).firstOrNull;
    if (widget.myGroup != null) {
      if (widget.myGroup!.id != group?.id) {
        showGroupDifference = true;

        AudioElement()
          ..src = 'assets/assets/error-sound-fx.wav'
          ..play();
      } else {
        AudioElement()
          ..src = 'assets/assets/Thank_You_Voice.mp3'
          ..play();
        signAttendance();
      }
    }

    makeAttendance();
    setState(() {
      groupName = group!.name;
      _nameController.text = widget.myStudent.name;
      _phoneController.text = widget.myStudent.phone;

      _parentPhoneController.text = widget.myStudent.parentPhone;

      _noteController.text = widget.myStudent.notes;
      _barcodeController.text = widget.myStudent.barcode;
      _addressController.text = widget.myStudent.location;
    });
  }

  void signAttendance() async {
    DocumentReference studentRef =
        firestoreInstance.collection('students').doc(widget.myStudent.id);

    String attendanceState = _formattedDate + ',1';

    // Future.delayed(const Duration(milliseconds: 50000), () {
    //   print('sssssss');
    // });
    await studentRef.set({
      'attendance': FieldValue.arrayUnion([attendanceState]),
    }, SetOptions(merge: true));

    widget.myStudent.attendance.add(attendanceState);
  }

  void makeAttendance() {
    final controller = CalendarControllerProvider.of(context).controller;
    for (var element in controller.events) {
      controller.remove(element);
    }
    for (String attendance in widget.myStudent.attendance) {
      if (attendance.split(',').last == '0') {
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
      } else if (attendance.split(',').last == '1') {
        final attendanceComponents = attendance.split(',');
        attendanceComponents.removeLast();

        final eventToOverWrite = CalendarEventData(
            date: DateTime(
                int.parse(attendanceComponents[0]),
                int.parse(attendanceComponents[1]),
                int.parse(attendanceComponents[2])),
            event: "Event 1",
            title: 'حضور',
            color: Colors.greenAccent);
        controller
            .removeWhere((element) => element.date == eventToOverWrite.date);

        final event = CalendarEventData(
            date: DateTime(
                int.parse(attendanceComponents[0]),
                int.parse(attendanceComponents[1]),
                int.parse(attendanceComponents[2])),
            event: "Event 1",
            title: 'حضور',
            color: Colors.greenAccent);

        controller.add(event);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();

    _parentPhoneController.dispose();

    _noteController.dispose();

    _barcodeController.dispose();

    _addressController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.myStudent.name),
        ),
        body: VisibilityDetector(
            onVisibilityChanged: (VisibilityInfo info) {
              visible = info.visibleFraction > 0;
            },
            key: Key('visible-detector-keys${DateTime.now()}'),
            child: BarcodeKeyboardListener(
              useKeyDownEvent: true,
              bufferDuration: const Duration(milliseconds: 2000),
              onBarcodeScanned: (barcode) {
                if (!visible) return;
                final enhancedBarcode = barcodeEnhanced(barcode);
                searchstudentWithBarcode(enhancedBarcode);
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
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
                                  final MyStudent? myStudent =
                                      await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditStudent(
                                          myStudent: widget.myStudent),
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
                                style: TextStyle(
                                    color: Colors.pinkAccent,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                width: 24,
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  DocumentReference studentRef =
                                      firestoreInstance
                                          .collection('students')
                                          .doc(widget.myStudent.id);

                                  var attendanceState = _formattedDate + ',0';
                                  studentRef.set({
                                    'attendance': FieldValue.arrayUnion(
                                        [attendanceState]),
                                  }, SetOptions(merge: true));
                                  Navigator.pop(context);
                                },
                                style: const ButtonStyle(
                                  backgroundColor:
                                      MaterialStatePropertyAll<Color>(
                                          Colors.orangeAccent),
                                ),
                                child: const Text(
                                  'تسجيل كإستثناء',
                                ),
                              ),
                            ],
                          ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                SizedBox(
                                  height: 16,
                                ),
                                SizedBox(
                                  width: 500,
                                  height: 300,
                                  child: Image.memory(
                                      widget.myStudent.profileImage.bytes),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: Text(
                                    groupName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.deepPurpleAccent),
                                  ),
                                ),
                                SizedBox(
                                  width: 500,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: inputsView(),
                                  ),
                                ),
                              ],
                            ),
                            calendarView()
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )));
  }

  IgnorePointer inputsView() {
    return IgnorePointer(
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'ادخل الاسم';
              }
              return null;
            },
            decoration: const InputDecoration(labelText: 'الاسم'),
            style: const TextStyle(color: Colors.black, fontSize: 20),
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
            style: const TextStyle(color: Colors.black),
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
            style: const TextStyle(color: Colors.black, fontSize: 20),
          ),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'العنوان'),
            style: const TextStyle(color: Colors.black, fontSize: 20),
          ),
          TextFormField(
            controller: _noteController,
            maxLines: 5,
            decoration: const InputDecoration(
                labelText: 'ملاحظات', alignLabelWithHint: true),
            style: const TextStyle(color: Colors.black, fontSize: 20),
          ),
          TextFormField(
            controller: _barcodeController,
            decoration: const InputDecoration(labelText: 'كود الطالب'),
            style: const TextStyle(color: Colors.black, fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget calendarView() {
    return const Expanded(
      child: SizedBox(
        height: 1000,
        child: MonthView(
          cellAspectRatio: 1.3,
        ),
      ),
    );
  }

  Future<void> searchstudentWithBarcode(String barcode) async {
    if (widget.myGroup == null) {
      return;
    }

    final bloc = BlocProvider.of<StudentsListBloc>(context, listen: false);
    final students = bloc.state.students;

    final student = students.firstWhere(
        (element) => element.barcode.toLowerCase() == barcode.toLowerCase());
    final groupBloc = BlocProvider.of<GroupListBloc>(context);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: groupBloc,
          child: StudentPreview(
            myStudent: student,
            myGroup: widget.myGroup,
          ),
        ),
      ),
    );
  }
}

String barcodeEnhanced(String _barcode) {
  return _barcode
      .replaceRange(0, 2, 'HT')
      .replaceAll('١', '1')
      .replaceAll('٢', '2')
      .replaceAll('٣', '3')
      .replaceAll('٤', '4')
      .replaceAll('٥', '5')
      .replaceAll('٦', '6')
      .replaceAll('٧', '7')
      .replaceAll('٨', '8')
      .replaceAll('٩', '9')
      .replaceAll('٠', '0');
}
