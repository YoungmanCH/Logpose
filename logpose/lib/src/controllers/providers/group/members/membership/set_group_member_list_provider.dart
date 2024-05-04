import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../models/database/user/user.dart';

/// Used to set group membership.
final setGroupMemberListProvider = StateNotifierProvider.autoDispose<
    _GroupMemberListNotifier, List<UserProfile>>(
  (ref) => _GroupMemberListNotifier(),
);

/// グループ作成の際にメンバーリストを管理。
class _GroupMemberListNotifier extends StateNotifier<List<UserProfile>> {
  _GroupMemberListNotifier() : super([]);

  void addMember(UserProfile newMember) {
    state = [...state, newMember];
  }

  void removeMember(String accountId) {
    state = state.where((member) => member.accountId != accountId).toList();
  }

  void resetMemberList() {
    state = [];
  }
}