import 'package:amazon_app/database/group/schedule/member_schedule/member_schedule_controller.dart';
import 'package:amazon_app/database/group/schedule/schedule/schedule_controller.dart';
import 'package:amazon_app/database/user/user.dart';
import 'package:amazon_app/database/user/user_controller.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

// Delete GroupSchedule, GroupMemberSchedule.
class DeleteSchedule {
  DeleteSchedule._internal();
  static final DeleteSchedule _instance = DeleteSchedule._internal();
  static DeleteSchedule get instance => _instance;

  static Future<void> delete(
    String groupId,
    String groupScheduleId,
    List<UserProfile?> groupMemberList,
  ) async {
    try {
      await Future.forEach<UserProfile?>(groupMemberList, (member) async {
        if (member == null) {
          return;
        }
        final memberDocId = await UserController.readUserDocIdWithAccountId(
          member.accountId,
        );
        final memberScheduleId = await GroupMemberScheduleController
            .readDocIdWithScheduleIdAndUserId(
          scheduleId: groupScheduleId,
          userDocId: memberDocId,
        );
        if (memberScheduleId == null) {
          throw Exception('Failed to reead memberSchedule ID.');
        }
        await GroupMemberScheduleController.delete(memberScheduleId);
      });
      await GroupScheduleController.delete(groupScheduleId);
    } on FirebaseException catch (e) {
      throw Exception('Failed to delete group schedule. $e');
    }
  }
}
