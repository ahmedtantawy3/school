import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school/bloc/StudentsList/students_list_bloc.dart';
import 'package:school/pages/student_preview.dart';
import 'package:school/pages/students_of_group.dart';
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
  List<MyGroup> allGroups = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // fetchAllGroups();
  }

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
        title: const Text('جميع الطلاب'),
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
            final enhancedBarcode = barcodeEnhanced(barcode);
            searchstudentWithBarcode(enhancedBarcode);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text('قائمة الطلاب'),
                ),
                const Divider(
                  thickness: 2,
                ),
                Expanded(
                  child: BlocBuilder<StudentsListBloc, StudentsListState>(
                    builder: (context, state) {
                      if (state is StudentsListInitial) {
                        return const Text('جارى عرض الطلاب');
                      }

                      var students = state.students;

                      return ListView.separated(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          MyStudent myStudent = students[index];
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
    // If a document was found, return it.
    // Note: This will only return the first document found, even if there are multiple documents with the same ID number.
    final bloc = BlocProvider.of<StudentsListBloc>(context, listen: false);
    final students = bloc.state.students;

    final student = students.firstWhere(
        (element) => element.barcode.toLowerCase() == barcode.toLowerCase());

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            StudentPreview(myStudent: student, allGroups: allGroups),
      ),
    );
  }

  Future<void> fetchAllGroups() async {
    List<MyGroup> allGroups = [];

    // Get all documents from the 'classes' collection
    QuerySnapshot classSnapshot =
        await firestoreInstance.collection('classes').get();

    // Iterate over each class document
    for (QueryDocumentSnapshot classDoc in classSnapshot.docs) {
      // Get the class ID
      String classId = classDoc.id;

      // Get all documents from the 'groups' subcollection of the class
      QuerySnapshot groupSnapshot = await firestoreInstance
          .collection('classes')
          .doc(classId)
          .collection('groups')
          .get();

      // Iterate over each group document and create MyGroup objects
      for (QueryDocumentSnapshot groupDoc in groupSnapshot.docs) {
        MyGroup myGroup = MyGroup.fromFirestore(groupDoc);
        allGroups.add(myGroup);
      }
    }

    setState(() {
      this.allGroups = allGroups;
    });
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
