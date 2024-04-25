import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

import '../../../../models/user/user.dart';

import '../../../../services/database/group_schedule_controller.dart';
import '../../../../services/database/member_schedule_controller.dart';
import '../../../../services/database/user_controller.dart';

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
      await Future.wait(groupMemberList.map((member) async {
        if (member == null) {
          return;
        }
        final memberScheduleId = await _fetchMemberScheduleId(
          member.accountId,
          groupScheduleId,
        );
        if (memberScheduleId == null) {
          debugPrint('Failed to reead memberSchedule ID.');
          return;
        }
        await _deleteMemberSchedule(memberScheduleId);
      }),);
      await _deleteGroupSchedule(groupScheduleId);
    } on FirebaseException catch (e) {
      throw Exception('Failed to delete group schedule. Error: $e');
    }
  }

  static Future<String?> _fetchMemberScheduleId(
    String accountId,
    String groupScheduleId,
  ) async {
    final userDocId = await _fetchUserDocId(accountId);
    return GroupMemberScheduleController.readDocIdWithScheduleIdAndUserId(
      scheduleId: groupScheduleId,
      userDocId: userDocId,
    );
  }

  static Future<String> _fetchUserDocId(String accountId) async {
    return UserController.readUserDocIdWithAccountId(accountId);
  }

  static Future<void> _deleteMemberSchedule(String memberScheduleId) async {
    await GroupMemberScheduleController.delete(memberScheduleId);
  }

  static Future<void> _deleteGroupSchedule(String groupScheduleId) async {
    await GroupScheduleController.delete(groupScheduleId);
  }
}