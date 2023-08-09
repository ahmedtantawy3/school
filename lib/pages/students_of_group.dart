import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school/bloc/StudentsList/students_list_bloc.dart';
import 'package:school/pages/student_preview.dart';
import 'package:school/services/my_group.dart';
import 'package:school/services/my_student.dart';
import '../bloc/GroupList/bloc/group_list_bloc.dart';
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
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _filter.removeListener(_onSearchChanged);
    _debounce?.cancel();
    _focusNode.dispose();

    super.dispose();
  }

  _StudentsOfGroupPageState() {
    _filter.addListener(_onSearchChanged);
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _filter.clear();
      }
    });
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
            final enhancedBarcode = barcodeEnhanced(barcode);
            searchstudentWithBarcode(enhancedBarcode);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _filter,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                        hintText: 'بحث',
                        border: InputBorder.none,
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: IconButton(
                            onPressed: () {
                              _filter.clear();
                            },
                            icon: const Icon(Icons.clear, color: Colors.grey))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text('طلبة ${widget.group.name} : '),
                ),
                const Divider(
                  thickness: 2,
                  color: Colors.blueAccent,
                ),
                Expanded(
                  child: BlocBuilder<StudentsListBloc, StudentsListState>(
                    builder: (context, state) {
                      if (state is StudentsListInitial) {
                        return const Text('جارى عرض الطلاب');
                      }

                      var students = state.students.where((element) =>
                          element.groupRef == widget.group.reference);

                      var filteredStudents = students
                          .where((element) =>
                              element.name.contains(filteredText) ||
                              element.phone.contains(filteredText) ||
                              element.parentPhone.contains(filteredText))
                          .toList();

                      return ListView.separated(
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, index) {
                          MyStudent myStudent = filteredStudents[index];
                          return ListTile(
                            title: Text(myStudent.name),
                            onTap: () {
                              final bloc =
                                  BlocProvider.of<GroupListBloc>(context);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider.value(
                                    value: bloc,
                                    child: StudentPreview(myStudent: myStudent),
                                  ),
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
                    const SizedBox(
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

    final bloc = BlocProvider.of<StudentsListBloc>(context, listen: false);
    final students = bloc.state.students;

    final student = students.firstWhere(
        (element) => element.barcode.toLowerCase() == barcode.toLowerCase());

    presentStudentPreview(student);
  }

  void presentStudentPreview(MyStudent student) async {
    final bloc = BlocProvider.of<GroupListBloc>(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (newContext) => BlocProvider.value(
          value: bloc,
          child: StudentPreview(
            myStudent: student,
            myGroup: widget.group,
          ),
        ),
      ),
    );

    // if (code != null) {
    //   // Delay the push to ensure the previous route completes its pop animation
    //   Future.delayed(Duration(milliseconds: 500), () {
    //     searchstudentWithBarcode(code);
    //   });
    // }
  }

  String fromAsciiString(String asciiString) {
    return asciiString
        .split(' ')
        .map((code) => String.fromCharCode(int.parse(code)))
        .join('');
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
