part of 'class_list_bloc.dart';

abstract class ClassListState extends Equatable {
  const ClassListState({required this.classes});
  final List<MyClass> classes;

  @override
  List<Object?> get props => [classes];
}

class ClassListInitial extends ClassListState {
  const ClassListInitial({required List<MyClass> classes})
      : super(classes: classes);
}

class ClassListUpdated extends ClassListState {
  const ClassListUpdated({required List<MyClass> classes})
      : super(classes: classes);
}
