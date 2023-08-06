import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school/pages/student_preview.dart';
import 'package:school/services/my_group.dart';
import 'package:school/services/my_student.dart';
import 'add_new_student.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';

class AllStudents extends StatefulWidget {
  @override
  _StudentsOfGroupPageState createState() => _StudentsOfGroupPageState();
}

class _StudentsOfGroupPageState extends State<AllStudents> {
  // final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final firestoreInstance = FirebaseFirestore.instance;
  late bool visible;
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
        title: Text('جميع الطلاب'),
      ),
      body: VisibilityDetector(
        onVisibilityChanged: (VisibilityInfo info) {
          visible = info.visibleFraction > 0;
        },
        key: const Key('visible-detector-key'),
        child: BarcodeKeyboardListener(
          bufferDuration: const Duration(milliseconds: 200),
          onBarcodeScanned: (barcode) {
            if (!visible) return;
            final enhancedBarcode = barcode
                .replaceAll('اف', 'ht')
                .replaceAll('آُ', 'HT')
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
                  child: Text('قائمة الطلاب'),
                ),
                const Divider(
                  thickness: 2,
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream:
                        firestoreInstance.collection('students').snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('Loading');
                      }

                      return ListView.separated(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot document =
                              snapshot.data!.docs[index];
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> searchstudentWithBarcode(String barcode) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('barcode'.toLowerCase(), isEqualTo: barcode.toLowerCase())
        .get();

    // If no document was found, return null.
    if (querySnapshot.docs.isEmpty) {
      return;
    }

    // If a document was found, return it.
    // Note: This will only return the first document found, even if there are multiple documents with the same ID number.

    final student = MyStudent.fromFirestore(querySnapshot.docs.first);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudentPreview(myStudent: student),
      ),
    );
  }
}
