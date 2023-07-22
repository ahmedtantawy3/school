import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school/bloc/GroupList/bloc/group_list_bloc.dart';
import '/services/my_class.dart';
import '/services/my_group.dart';
import 'students_of_group.dart';

class MyGroupsPage extends StatefulWidget {
  final MyClass myClass;

  MyGroupsPage({required this.myClass});

  @override
  _MyGroupsPageState createState() => _MyGroupsPageState();
}

class _MyGroupsPageState extends State<MyGroupsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Groups of ${widget.myClass.name}'),
      ),
      body: Column(children: [
        Expanded(
          child: BlocBuilder<GroupListBloc, GroupListState>(
              builder: ((context, state) {
            if (state is GroupListInitial) {
              return Text('Something went wrong');
            }
            final groups = state.groups;

            return ListView.builder(
                itemCount: groups.length,
                itemBuilder: ((context, index) {
                  MyGroup myGroup = groups[index];
                  return ListTile(
                    title: Text(myGroup.name),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              StudentsOfGroupPage(group: myGroup),
                        ),
                      );
                    },
                  );
                }));
          })),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        NewGroupPage(myClass: widget.myClass)),
              );
            },
            child: const Text('Add group'),
          ),
        ),
      ]),
    );
  }
}

class NewGroupPage extends StatefulWidget {
  final MyClass myClass;

  NewGroupPage({required this.myClass});

  @override
  _NewGroupPageState createState() => _NewGroupPageState();
}

class _NewGroupPageState extends State<NewGroupPage> {
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
          firestoreInstance.collection('classes').doc(widget.myClass.id);
      DocumentReference groupRef = classRef.collection('groups').doc();
      MyGroup myGroup =
          MyGroup(id: groupRef.id, name: _nameController.text, reference: null);
      groupRef.set(myGroup.toFirestore());

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Group'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              decoration: InputDecoration(labelText: 'Name'),
            ),
            ElevatedButton(
              onPressed: _save,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
