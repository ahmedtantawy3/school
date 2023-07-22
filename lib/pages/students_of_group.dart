import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school/pages/student_preview.dart';
import 'package:school/services/my_group.dart';
import 'package:school/services/my_student.dart';
import 'add_new_student.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // void _save() {
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
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text('Students of ${widget.group.name} : '),
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
                      DocumentSnapshot document = snapshot.data!.docs[index];
                      MyStudent myStudent = MyStudent.fromFirestore(document);
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
                  child: const Text('Add student'),
                ),
                SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Sessions'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
