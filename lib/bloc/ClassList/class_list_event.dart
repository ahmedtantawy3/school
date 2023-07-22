part of 'class_list_bloc.dart';

abstract class ClassListEvent extends Equatable {
  const ClassListEvent();

  @override
  List<Object> get props => [];
}

class LoadClasses extends ClassListEvent {}

class ClassesLoaded extends ClassListEvent {
  final List<MyClass> classes;

  const ClassesLoaded(this.classes);

  @override
  List<Object> get props => [classes];
}

class AddClass extends ClassListEvent {
  final MyClass myClass;

  const AddClass(this.myClass);

  @override
  List<Object> get props => [myClass];
}

class UpdateClass extends ClassListEvent {
  final MyClass myClass;

  const UpdateClass(this.myClass);

  @override
  List<Object> get props => [myClass];
}

class DeleteClass extends ClassListEvent {
  final MyClass myClass;

  const DeleteClass(this.myClass);

  @override
  List<Object> get props => [myClass];
}
