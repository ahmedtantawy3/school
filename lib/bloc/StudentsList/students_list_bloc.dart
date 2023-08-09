import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:school/services/my_student.dart';

part 'students_list_event.dart';
part 'students_list_state.dart';

class StudentsListBloc extends Bloc<StudentsListEvent, StudentsListState> {
  final CollectionReference studentsCollection =
      FirebaseFirestore.instance.collection('students');
  // late var _classesStream = studentsCollection.snapshots().listen((snapshot) {
  //   final classes = snapshot.docs
  //       .map((doc) => MyClass(
  //             id: doc.id,
  //             name: doc['name'],
  //           ))
  //       .toList();

  //   add(ClassesLoaded(classes));
  // });

  StudentsListBloc() : super(const StudentsListInitial(students: [])) {
    on<LoadStudents>(_loadClasses);
    on<StudentsLoaded>(_studentsLoaded);

    on<AddStudent>(_addClass);
    on<UpdateStudent>(_updateStudent);
    on<DeleteStudent>(_deleteStudent);

    // _classesStream;

    // _classesStream.onData((snapshot) {
    //   final classes = snapshot.docs
    //       .map((doc) => MyClass(
    //             id: doc.id,
    //             name: doc['name'],
    //           ))
    //       .toList();

    //   add(ClassesLoaded(classes));
    // });
  }

  Future<void> _loadClasses(
      LoadStudents event, Emitter<StudentsListState> emit) async {
    try {
      studentsCollection.snapshots().listen((snapshot) {
        final students =
            snapshot.docs.map((doc) => MyStudent.fromFirestore(doc)).toList();

        add(StudentsLoaded(students));
      });
    } catch (_) {}
  }

  void _studentsLoaded(
      StudentsLoaded event, Emitter<StudentsListState> emit) async {
    emit(StudentsUpdated(students: event.myStudent));
  }

  void _addClass(AddStudent event, Emitter<StudentsListState> emit) async {
    await studentsCollection.add(event.myStudent.toFirestore());
  }

  void _updateStudent(
      UpdateStudent event, Emitter<StudentsListState> emit) async {
    await studentsCollection
        .doc(event.myStudent.id)
        .update(event.myStudent.toFirestore());
  }

  void _deleteStudent(
      DeleteStudent event, Emitter<StudentsListState> emit) async {
    await studentsCollection.doc(event.myStudent.id).delete();
  }
}
