part of 'group_list_bloc.dart';

abstract class GroupListState extends Equatable {
  const GroupListState({required this.groups});
  final List<MyGroup> groups;

  @override
  List<Object> get props => [groups];
}

class GroupListInitial extends GroupListState {
  const GroupListInitial({required List<MyGroup> groups})
      : super(groups: groups);
}

class GroupListUpdated extends GroupListState {
  const GroupListUpdated({required List<MyGroup> groups})
      : super(groups: groups);
}
