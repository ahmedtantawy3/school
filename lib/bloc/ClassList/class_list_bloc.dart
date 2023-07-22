import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../services/my_class.dart';

part 'class_list_event.dart';
part 'class_list_state.dart';

class ClassListBloc extends Bloc<ClassListEvent, ClassListState> {
  final CollectionReference classesCollection =
      FirebaseFirestore.instance.collection('classes');
  // late var _classesStream = classesCollection.snapshots().listen((snapshot) {
  //   final classes = snapshot.docs
  //       .map((doc) => MyClass(
  //             id: doc.id,
  //             name: doc['name'],
  //           ))
  //       .toList();

  //   add(ClassesLoaded(classes));
  // });

  ClassListBloc() : super(const ClassListInitial(classes: [])) {
    on<LoadClasses>(_loadClasses);
    on<ClassesLoaded>(_classesLoaded);

    on<AddClass>(_addClass);
    on<UpdateClass>(_updateClass);
    on<DeleteClass>(_deleteClass);

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
      LoadClasses event, Emitter<ClassListState> emit) async {
    try {
      classesCollection.snapshots().listen((snapshot) {
        final classes = snapshot.docs
            .map((doc) => MyClass(
                  id: doc.id,
                  name: doc['name'],
                ))
            .toList();

        add(ClassesLoaded(classes));
      });
    } catch (_) {}
  }

  void _classesLoaded(ClassesLoaded event, Emitter<ClassListState> emit) async {
    emit(ClassListUpdated(classes: event.classes));
  }

  void _addClass(AddClass event, Emitter<ClassListState> emit) async {
    await classesCollection.add(event.myClass.toFirestore());
  }

  void _updateClass(UpdateClass event, Emitter<ClassListState> emit) async {
    await classesCollection
        .doc(event.myClass.id)
        .update(event.myClass.toFirestore());
  }

  void _deleteClass(DeleteClass event, Emitter<ClassListState> emit) async {
    await classesCollection.doc(event.myClass.id).delete();
  }
}
