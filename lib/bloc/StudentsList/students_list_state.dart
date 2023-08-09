part of 'students_list_bloc.dart';

abstract class StudentsListState extends Equatable {
  const StudentsListState({required this.students});
  final List<MyStudent> students;

  @override
  List<Object?> get props => [students];
}

class StudentsListInitial extends StudentsListState {
  const StudentsListInitial({required List<MyStudent> students})
      : super(students: students);
}

class StudentsUpdated extends StudentsListState {
  const StudentsUpdated({required List<MyStudent> students})
      : super(students: students);
}
