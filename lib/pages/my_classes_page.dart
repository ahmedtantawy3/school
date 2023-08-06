import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school/bloc/ClassList/class_list_bloc.dart';
import 'package:school/bloc/GroupList/bloc/group_list_bloc.dart';
import 'package:school/services/my_class.dart';
import 'groups_of_class.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyClassesPage extends StatefulWidget {
  MyClassesPage({super.key});

  @override
  State<MyClassesPage> createState() => _MyClassesPageState();
}

class _MyClassesPageState extends State<MyClassesPage> {
  final firestoreInstance = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('الصفوف'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewClassPage()),
                );
              },
            )
          ],
        ),
        body: BlocBuilder<ClassListBloc, ClassListState>(
          builder: (context, state) {
            if (state is ClassListInitial) {
              return const Text('Something went wrong');
            }
            var classes = state.classes;
            return Column(
              children: [
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                      itemCount: classes.length,
                      itemBuilder: (context, index) {
                        var myClass = classes[index];
                        return ListTile(
                          title: Text(myClass.name),
                          onTap: () {
                            // Navigate to MyGroupsPage when this ListTile is tapped
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => BlocProvider(
                                        create: (context) =>
                                            GroupListBloc(myClass: myClass)
                                              ..add(LoadGroups()),
                                        child: MyGroupsPage(myClass: myClass),
                                      ))),
                            );
                          },
                        );
                      }),
                ),
              ],
            );
          },
        ));
  }
}

class NewClassPage extends StatefulWidget {
  @override
  _NewClassPageState createState() => _NewClassPageState();
}

class _NewClassPageState extends State<NewClassPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final firestoreInstance = FirebaseFirestore.instance;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      DocumentReference classRef =
          firestoreInstance.collection('classes').doc();
      MyClass myClass = MyClass(id: '', name: _nameController.text);
      classRef.set(myClass.toFirestore());

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('صف جديد'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'ادخل اسم الصف';
                }
                return null;
              },
              decoration: const InputDecoration(labelText: 'الاسم'),
            ),
            ElevatedButton(
              onPressed: _save,
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}
