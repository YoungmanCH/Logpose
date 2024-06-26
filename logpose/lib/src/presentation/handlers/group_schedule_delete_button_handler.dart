import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entity/user_profile.dart';

import '../controllers/group_schedule/group_schedule_deletion_controller.dart';

class GroupScheduleDeleteHandler {
  const GroupScheduleDeleteHandler({
    required this.ref,
    required this.groupMemberList,
    required this.groupScheduleId,
  });

  final WidgetRef ref;
  final List<UserProfile?> groupMemberList;
  final String groupScheduleId;

  Future<void> handleDeleteSchedule() async {
    final deleteController = ref.read(groupScheduleDeletionControllerProvider);
    await deleteController.deleteSchedule(groupMemberList, groupScheduleId);
  }
}
