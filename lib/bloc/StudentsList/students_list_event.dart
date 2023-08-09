part of 'students_list_bloc.dart';

abstract class StudentsListEvent extends Equatable {
  const StudentsListEvent();

  @override
  List<Object> get props => [];
}

class LoadStudents extends StudentsListEvent {}

class StudentsLoaded extends StudentsListEvent {
  final List<MyStudent> myStudent;

  const StudentsLoaded(this.myStudent);

  @override
  List<Object> get props => [myStudent];
}

class AddStudent extends StudentsListEvent {
  final MyStudent myStudent;

  const AddStudent(this.myStudent);

  @override
  List<Object> get props => [myStudent];
}

class UpdateStudent extends StudentsListEvent {
  final MyStudent myStudent;

  const UpdateStudent(this.myStudent);

  @override
  List<Object> get props => [myStudent];
}

class DeleteStudent extends StudentsListEvent {
  final MyStudent myStudent;

  const DeleteStudent(this.myStudent);

  @override
  List<Object> get props => [myStudent];
}
