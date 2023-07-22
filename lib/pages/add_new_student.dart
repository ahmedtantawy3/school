import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:school/services/my_group.dart';
import 'package:school/services/my_student.dart';

import '../camera_page.dart';
import 'package:camera/camera.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';

class AddNewStudent extends StatefulWidget {
  final MyGroup myGroup;

  const AddNewStudent({super.key, required this.myGroup});

  @override
  // ignore: library_private_types_in_public_api
  _AddNewStudentState createState() => _AddNewStudentState();
}

class _AddNewStudentState extends State<AddNewStudent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _noteController = TextEditingController();
  final _barcodeController = TextEditingController();

  final firestoreInstance = FirebaseFirestore.instance;

  bool isUploading = false;
  List<MyGroup> allGroups = [];
  MyGroup? selectedGroup;
  Uint8List? imageData;
  String? _barcode;
  late bool visible;
  @override
  void initState() {
    super.initState();
    selectedGroup = widget.myGroup;
    fetchAllGroups();
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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      if (imageData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select image'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      DocumentReference studentRef =
          firestoreInstance.collection('students').doc();

      MyStudent myStudent = MyStudent(
        id: studentRef.id,
        name: _nameController.text,
        groupRef: selectedGroup?.reference,
        profileImage: Blob(imageData!),
        notes: _noteController.text,
        parentPhone: _parentPhoneController.text,
        phone: _phoneController.text, // add the imageUrl
      );

      studentRef.set(myStudent.toFirestore());

      selectedGroup!.reference!.set({
        'studentIds': FieldValue.arrayUnion([studentRef.id]),
      }, SetOptions(merge: true));

      Navigator.pop(context);
    }
  }

  Future pickImageFromCamera() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();

    // Get a specific camera from the list of available cameras.
    final firstCamera = cameras.first;
    // ignore: use_build_context_synchronously
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakePictureScreen(
          camera: firstCamera,
          onDataSelected: (data) {
            setState(() {
              imageData = data;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Student'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              if (imageData != null)
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Image.memory(imageData!),
                )
              else
                Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                  child: const Icon(Icons.person),
                ),
              ElevatedButton(
                onPressed: pickImageFromCamera,
                child: const Text('Capture Image'),
              ),
              TextFormField(
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: _phoneController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone';
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              TextFormField(
                controller: _parentPhoneController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a parent phone';
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: 'Parent Phone'),
              ),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              VisibilityDetector(
                onVisibilityChanged: (VisibilityInfo info) {
                  visible = info.visibleFraction > 0;
                },
                key: const Key('visible-detector-key'),
                child: BarcodeKeyboardListener(
                  bufferDuration: const Duration(milliseconds: 200),
                  onBarcodeScanned: (barcode) {
                    if (!visible) return;
                    setState(() {
                      _barcode = barcode;
                      _barcodeController.text = barcode;
                    });
                  },
                  child: TextFormField(
                    controller: _barcodeController,
                    readOnly: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Student barcode';
                      }
                      return null;
                    },
                    decoration:
                        const InputDecoration(labelText: 'Student code'),
                  ),
                ),
              ),
              DropdownButtonFormField<MyGroup>(
                value: getDefaultGroup(),
                items: allGroups.map((group) {
                  return DropdownMenuItem<MyGroup>(
                    value: group,
                    child: Text(group.name),
                  );
                }).toList(),
                onChanged: (MyGroup? newValue) {
                  setState(() {
                    selectedGroup = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a group';
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: 'Group'),
              ),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  MyGroup? getDefaultGroup() {
    if (selectedGroup == null || allGroups.isEmpty) {
      return null;
    } else {
      return allGroups.firstWhere((element) => element.id == selectedGroup!.id);
    }
  }
}
