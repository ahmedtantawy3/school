import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school/pages/student_preview.dart';
import 'package:school/services/my_group.dart';
import 'package:school/services/my_student.dart';
import 'add_new_student.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';

class StudentsOfGroupPage extends StatefulWidget {
  final MyGroup group;

  StudentsOfGroupPage({required this.group});

  @override
  _StudentsOfGroupPageState createState() => _StudentsOfGroupPageState();
}

class _StudentsOfGroupPageState extends State<StudentsOfGroupPage> {
  // final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final firestoreInstance = FirebaseFirestore.instance;
  bool sessionActivated = false;
  late bool visible;
  String filteredText = '';
  final TextEditingController _filter = TextEditingController();
  Timer? _debounce;
  @override
  void dispose() {
    _nameController.dispose();
    _filter.removeListener(_onSearchChanged);
    _debounce?.cancel();
    super.dispose();
  }

  _StudentsOfGroupPageState() {
    _filter.addListener(_onSearchChanged);
  }
  _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      // Call the function to filter the list here
      print("Filtering with ${_filter.text}");
      setState(() {
        filteredText = _filter.text;
      });
    });
  }
  // void _save() {HT 001417

  //   if (_formKey.currentState!.validate()) {
  //     MyStudent myStudent = MyStudent(
  //       id: '',
  //       name: _nameController.text,
  //       groupRef: widget.group.classRef,
  //     );

  //     firestoreInstance.collection('students').add(myStudent.toFirestore());

  //     _nameController.clear();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.group.name}'),
      ),
      body: VisibilityDetector(
        onVisibilityChanged: (VisibilityInfo info) {
          visible = info.visibleFraction > 0;
        },
        key: const Key('visible-detector-key'),
        child: BarcodeKeyboardListener(
          useKeyDownEvent: true,
          bufferDuration: const Duration(milliseconds: 2000),
          onBarcodeScanned: (barcode) {
            if (!visible) return;
            final enhancedBarcode = barcode
                .replaceAll('اف', 'ht')
                .replaceAll('آُ', 'HT')
                .replaceAll('ألإ', 'HT')
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
            searchstudentWithBarcode(enhancedBarcode);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: TextField(
                    controller: _filter,
                    decoration: const InputDecoration(
                      labelText: 'بحث',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text('طلبة ${widget.group.name} : '),
                ),
                const Divider(
                  thickness: 2,
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: firestoreInstance
                        .collection('students')
                        .where('groupRef', isEqualTo: widget.group.reference)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshots) {
                      if (snapshots.hasError) {
                        return Text('Something went wrong');
                      }

                      if (snapshots.connectionState ==
                          ConnectionState.waiting) {
                        return Text('Loading');
                      }
                      var filteredResult = snapshots.data!.docs
                          .where((element) =>
                              (element['name'] as String)
                                  .contains(filteredText) ||
                              (element['phone'] as String)
                                  .contains(filteredText) ||
                              (element['parentPhone'] as String)
                                  .contains(filteredText))
                          .toList();

                      return ListView.separated(
                        itemCount: filteredResult.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot document = filteredResult[index];
                          MyStudent myStudent =
                              MyStudent.fromFirestore(document);
                          return ListTile(
                            title: Text(myStudent.name),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      StudentPreview(myStudent: myStudent),
                                ),
                              );
                            },
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const Divider(
                            height: 1,
                            thickness: 1,
                          ); // return the divider
                        },
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddNewStudent(myGroup: widget.group),
                          ),
                        );
                      },
                      child: const Text('إضافة طالب'),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateColor.resolveWith(
                              (states) => sessionActivated
                                  ? Colors.red
                                  : Colors.green)),
                      onPressed: () {
                        setState(() {
                          sessionActivated = !sessionActivated;
                        });
                      },
                      child: sessionActivated
                          ? const Text('إنهاء الجلسة')
                          : const Text('تفعيل الجلسة'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> searchstudentWithBarcode(String barcode) async {
    if (!sessionActivated) {
      return;
    }
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('groupRef', isEqualTo: widget.group.reference)
        .get();

    // If no document was found, return null.
    if (querySnapshot.docs.isEmpty) {
      return;
    }

    // If a document was found, return it.
    // Note: This will only return the first document found, even if there are multiple documents with the same ID number.
    final students = querySnapshot.docs.map((e) => MyStudent.fromFirestore(e));
    final student = students.firstWhere(
        (element) => element.barcode.toLowerCase() == barcode.toLowerCase());

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudentPreview(
          myStudent: student,
          myGroup: widget.group,
        ),
      ),
    );
  }

  String fromAsciiString(String asciiString) {
    return asciiString
        .split(' ')
        .map((code) => String.fromCharCode(int.parse(code)))
        .join('');
  }
}
