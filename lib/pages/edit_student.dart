import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:school/pages/students_of_group.dart';
import 'package:school/services/my_group.dart';
import 'package:school/services/my_student.dart';
// import 'package:universal_html/html.dart' as html;

import '../camera_page.dart';
import 'package:camera/camera.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';

class EditStudent extends StatefulWidget {
  final MyStudent myStudent;

  const EditStudent({super.key, required this.myStudent});

  @override
  // ignore: library_private_types_in_public_api
  _AddNewStudentState createState() => _AddNewStudentState();
}

class _AddNewStudentState extends State<EditStudent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _noteController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _addressController = TextEditingController();

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
    if (widget.myStudent.groupRef != null) {
      getFieldValue(widget.myStudent.groupRef!);
    }
    fetchAllGroups();
  }

  void getFieldValue(DocumentReference docRef) async {
    final snapShot = await docRef.get();
    final group = MyGroup.fromFirestore(snapShot);
    setState(() {
      imageData = widget.myStudent.profileImage.bytes;
      selectedGroup = group;

      _nameController.text = widget.myStudent.name;
      _phoneController.text = widget.myStudent.phone;

      _parentPhoneController.text = widget.myStudent.parentPhone;

      _noteController.text = widget.myStudent.notes;
      _barcodeController.text = widget.myStudent.barcode;
      _addressController.text = widget.myStudent.location;
    });
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
            content: Text('اختر الصورة'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      DocumentReference studentRef =
          firestoreInstance.collection('students').doc(widget.myStudent.id);

      MyStudent myStudent = MyStudent(
        id: widget.myStudent.id,
        name: _nameController.text,
        groupRef: selectedGroup?.reference,
        profileImage: Blob(imageData!),
        notes: _noteController.text,
        parentPhone: _parentPhoneController.text,
        phone: _phoneController.text,
        barcode: _barcodeController.text,
        location: _addressController.text,
        attendance: widget.myStudent.attendance,
      );

      studentRef.update(myStudent.toFirestore());

      selectedGroup!.reference!.set({
        'studentIds': FieldValue.arrayUnion([studentRef.id]),
      }, SetOptions(merge: true));

      Navigator.pop(context, myStudent);
    }
  }

  Future pickImageFromCamera() async {
    WidgetsFlutterBinding.ensureInitialized();

    //  Navigate to the second page and wait for the result
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraPage()),
    );

    // Set the image data to the result
    if (mounted) {
      setState(() {
        imageData = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل الطالب'),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                  child: const Text('التقاط الصورة'),
                ),
                TextFormField(
                  controller: _nameController,
                  inputFormatters: [ArabicToEnglishNumberInputFormatter()],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'ادخل الاسم';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'الاسم'),
                ),
                TextFormField(
                  controller: _phoneController,
                  inputFormatters: [ArabicToEnglishNumberInputFormatter()],
                  keyboardType:
                      const TextInputType.numberWithOptions(signed: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'ادخل رقم الطالب';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'رقم الطالب'),
                ),
                TextFormField(
                  controller: _parentPhoneController,
                  keyboardType:
                      const TextInputType.numberWithOptions(signed: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'ادخل رقم ولى الامر';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'رقم ولى الامر'),
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'العنوان'),
                ),
                TextFormField(
                  controller: _noteController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                      labelText: 'ملاحظات', alignLabelWithHint: true),
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
                        final enhancedBarcode = barcodeEnhanced(barcode);
                        if (!enhancedBarcode.toLowerCase().contains('ht')) {
                          return;
                        }
                        _barcode = enhancedBarcode;
                        _barcodeController.text = enhancedBarcode;
                      });
                    },
                    child: TextFormField(
                      controller: _barcodeController,
                      // readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'ادخل كود الطالب';
                        }
                        return null;
                      },
                      decoration:
                          const InputDecoration(labelText: 'كود الطالب'),
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
                      return 'اختر المجموعة';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'المجموعة'),
                ),
                ElevatedButton(
                  onPressed: _save,
                  child: const Text('حفظ'),
                ),
              ],
            ),
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

class ArabicToEnglishNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String translatedText = newValue.text.replaceAllMapped(
      RegExp(r'[٠١٢٣٤٥٦٧٨٩]'),
      (match) {
        switch (match.group(0)) {
          case '٠':
            return '0';
          case '١':
            return '1';
          case '٢':
            return '2';
          case '٣':
            return '3';
          case '٤':
            return '4';
          case '٥':
            return '5';
          case '٦':
            return '6';
          case '٧':
            return '7';
          case '٨':
            return '8';
          case '٩':
            return '9';
          default:
            return match.group(0) ?? '';
        }
      },
    );
    return newValue.copyWith(text: translatedText);
  }
}
