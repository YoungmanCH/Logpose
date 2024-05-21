import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/facade/group_facade.dart';

import '../../../../domain/entity/user_profile.dart';

import '../../../../domain/model/group_id_and_schedule_id_and_member_list_model.dart';
import '../../../../domain/model/group_schedule_and_id_model.dart';

import '../../../../domain/providers/group/members/listen_group_member_profile_list.dart';
import '../../../../domain/providers/group/schedule/listen_all_group_schedule_and_id_list_provider.dart';

import '../../common/back_to_page_button.dart';

import '../slide/slider/schedule_list_and_joined_group_tab_slider.dart';

class GroupSettingNavigationBar extends CupertinoNavigationBar {
  GroupSettingNavigationBar({
    super.key,
    required this.context,
    required this.ref,
    required this.mounted,
    required this.groupId,
  }) : super(
          leading: const BackToPageButton(),
          backgroundColor: const Color.fromARGB(255, 233, 233, 246),
          border: const Border(
            bottom: BorderSide(color: Color.fromARGB(0, 0, 0, 0)),
          ),
          middle: _middle(context),
          trailing: _trailing(context, ref, mounted, groupId),
        );
  final BuildContext context;
  final WidgetRef ref;
  final bool mounted;
  final String groupId;

  static Widget _middle(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFD9D9D9),
            offset: Offset(0, 2),
            blurRadius: 2,
            spreadRadius: 1,
          ),
        ],
        color: const Color(0xFF7B61FF),
        borderRadius: BorderRadius.circular(80),
      ),
      child: const Center(
        child: Text(
          '団体編集',
          style: TextStyle(
            color: CupertinoColors.white,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  static Widget _trailing(
    BuildContext context,
    WidgetRef ref,
    bool mounted,
    String groupId,
  ) {
    return CupertinoButton(
      onPressed: () => _onPressed(
        context,
        ref,
        mounted,
        groupId,
      ),
      child: const Icon(
        CupertinoIcons.delete,
        color: Color(0xFF7B61FF),
        size: 25,
      ),
    );
  }

  static Future<void> _onPressed(
    BuildContext context,
    WidgetRef ref,
    bool mounted,
    String groupId,
  ) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('団体を削除しますか?'),
          content: const Text('削除後、元に戻すことはできません。'),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => _yes(context, ref, mounted, groupId),
              child: const Text('Yes'),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => _no(context),
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _yes(
    BuildContext context,
    WidgetRef ref,
    bool mounted,
    String groupId,
  ) async {
    await _deleteSchedule(context, ref, mounted, groupId);
  }

  static Future<void> _deleteSchedule(
    BuildContext context,
    WidgetRef ref,
    bool mounted,
    String groupId,
  ) async {
    ref.watch(listenGroupMemberProfileListProvider(groupId)).when(
          data: (groupMemberList) async {
            await _watchGroupScheduleAndId(ref, groupId, groupMemberList);
          },
          loading: () => [const SizedBox.shrink()],
          error: (error, stack) => [Text('$error')],
        );
    if (!mounted) {
      return;
    }
    await _pushAndRemoveUntil(context);
  }

  static Future<void> _watchGroupScheduleAndId(
    WidgetRef ref,
    String groupId,
    List<UserProfile?> groupMemberList,
  ) async {
    ref.watch(listenAllGroupScheduleAndIdListProvider(groupId)).when(
          data: (groupScheduleList) async {
            await _deleteGroup(
              ref,
              groupScheduleList,
              groupId,
              groupMemberList,
            );
          },
          loading: () => [const SizedBox.shrink()],
          error: (error, stack) => [Text('$error')],
        );
  }

  static Future<void> _deleteGroup(
    WidgetRef ref,
    List<GroupScheduleAndId?> groupScheduleList,
    String groupId,
    List<UserProfile?> groupMemberList,
  ) async {
    if (groupScheduleList.isEmpty) {
      await _delete(ref, groupId, null, groupMemberList);
    }
    groupScheduleList.map((data) async {
      if (data == null) {
        return;
      }
      await _delete(ref, groupId, data.groupScheduleId, groupMemberList);
    });
  }

  static Future<void> _delete(
    WidgetRef ref,
    String groupId,
    String? groupScheduleId,
    List<UserProfile?> groupMemberList,
  ) async {
    final groupFacade = ref.read(groupFacadeProvider);
    await groupFacade.deleteGroup(
      GroupIdAndScheduleIdAndMemberList(
        groupId: groupId,
        groupScheduleId: groupScheduleId,
        groupMemberList: groupMemberList,
      ),
    );
  }

  static Future<void> _pushAndRemoveUntil(BuildContext context) async {
    await Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute<CupertinoPageRoute<dynamic>>(
        builder: (context) => const ScheduleListAndJoinedGroupTabSlider(),
      ),
      (_) => false,
    );
  }

  static void _no(BuildContext context) {
    Navigator.pop(context);
  }
}
