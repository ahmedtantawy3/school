// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// // void main() {
// //   runApp(MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'My Classes',
// //       theme: ThemeData(
// //         primarySwatch: Colors.blue,
// //       ),
// //       home: MyClassesPage(),
// //     );
// //   }
// // }

// class MyClassesPage extends StatelessWidget {
//   final firestoreInstance = FirebaseFirestore.instance;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('My Classes'),
//         actions: <Widget>[
//           IconButton(
//             icon: Icon(Icons.add),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => NewClassPage()),
//               );
//             },
//           )
//         ],
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: firestoreInstance.collection('classes').snapshots(),
//         builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.hasError) {
//             return Text('Something went wrong');
//           }

//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Text('Loading');
//           }

//           return ListView(
//             children: snapshot.data!.docs.map((DocumentSnapshot document) {
//               MyClass myClass = MyClass.fromFirestore(document);
//               return ListTile(
//                 title: Text(myClass.name),
//               );
//             }).toList(),
//           );
//         },
//       ),
//     );
//   }
// }

// class NewClassPage extends StatefulWidget {
//   @override
//   _NewClassPageState createState() => _NewClassPageState();
// }

// class _NewClassPageState extends State<NewClassPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final firestoreInstance = FirebaseFirestore.instance;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     super.dispose();
//   }

//   void _save() {
//     if (_formKey.currentState!.validate()) {
//       MyClass myClass = MyClass(id: '', name: _nameController.text);
//       firestoreInstance.collection('classes').add(myClass.toFirestore());

//       Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('New Class'),
//       ),
//       body: Form(
//         key: _formKey,
//         child: Column(
//           children: <Widget>[
//             TextFormField(
//               controller: _nameController,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter a name';
//                 }
//                 return null;
//               },
//               decoration: InputDecoration(labelText: 'Name'),
//             ),
//             ElevatedButton(
//               onPressed: _save,
//               child: Text('Save'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class MyClass {
//   String id;
//   String name;

//   MyClass({required this.id, required this.name});

//   factory MyClass.fromFirestore(DocumentSnapshot doc) {
//     Map data = doc.data() as Map<String, dynamic>;
//     String id = doc.id;

//     return MyClass(
//       id: id,
//       name: data['name'] ?? '',
//     );
//   }

//   Map<String, dynamic> toFirestore() => {
//         'name': name,
//       };
// }
