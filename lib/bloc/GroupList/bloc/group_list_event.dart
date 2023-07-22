part of 'group_list_bloc.dart';

abstract class GroupListEvent extends Equatable {
  const GroupListEvent();

  @override
  List<Object> get props => [];
}

class LoadGroups extends GroupListEvent {}

class GroupsLoaded extends GroupListEvent {
  final List<MyGroup> groups;

  const GroupsLoaded(this.groups);
}

class AddGroup extends GroupListEvent {
  final MyGroup myGroup;

  const AddGroup(this.myGroup);
}

class UpdateGroup extends GroupListEvent {
  final MyGroup myGroup;

  const UpdateGroup(this.myGroup);
}

class DeleteGroup extends GroupListEvent {
  final MyGroup myGroup;

  const DeleteGroup(this.myGroup);
}
