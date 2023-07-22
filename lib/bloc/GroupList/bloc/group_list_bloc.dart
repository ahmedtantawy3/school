import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:school/services/my_class.dart';

import '../../../services/my_group.dart';

part 'group_list_event.dart';
part 'group_list_state.dart';

class GroupListBloc extends Bloc<GroupListEvent, GroupListState> {
  late final CollectionReference groupsCollection;

  final MyClass myClass;

  GroupListBloc({required this.myClass}) : super(GroupListInitial(groups: [])) {
    groupsCollection = FirebaseFirestore.instance
        .collection('classes')
        .doc(myClass.id)
        .collection('groups');
    on<LoadGroups>(_loadClasses);
    on<GroupsLoaded>(_classesLoaded);

    on<AddGroup>(_addClass);
    on<UpdateGroup>(_updateClass);
    on<DeleteGroup>(_deleteClass);
  }

  Future<void> _loadClasses(
      LoadGroups event, Emitter<GroupListState> emit) async {
    try {
      groupsCollection.snapshots().listen((snapshot) {
        final groups =
            snapshot.docs.map((doc) => MyGroup.fromFirestore(doc)).toList();

        add(GroupsLoaded(groups));
      });
    } catch (_) {}
  }

  void _classesLoaded(GroupsLoaded event, Emitter<GroupListState> emit) async {
    emit(GroupListUpdated(groups: event.groups));
  }

  void _addClass(AddGroup event, Emitter<GroupListState> emit) async {
    await groupsCollection.add(event.myGroup.toFirestore());
  }

  void _updateClass(UpdateGroup event, Emitter<GroupListState> emit) async {
    await groupsCollection
        .doc(event.myGroup.id)
        .update(event.myGroup.toFirestore());
  }

  void _deleteClass(DeleteGroup event, Emitter<GroupListState> emit) async {
    await groupsCollection.doc(event.myGroup.id).delete();
  }
}
