import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../validation/validator/validator_controller.dart';

import '../../app/facade/auth_facade.dart';
import '../../app/facade/group_membership_facade.dart';
import '../../app/facade/user_service_facade.dart';

import '../../domain/entity/user_profile.dart';

final searchUserNotifierProvider = StateNotifierProvider.family
    .autoDispose<_SearchUserNotifier, UserProfile?, String?>(
  _SearchUserNotifier.new,
);

class _SearchUserNotifier extends StateNotifier<UserProfile?> {
  _SearchUserNotifier(this.ref, this.groupId)
      : _userServiceFacade = ref.read(userServiceFacadeProvider),
        _memberFacade = ref.read(groupMembershipFacadeProvider),
        _validator = ref.read(validatorControllerProvider),
        super(null) {
    _init();
  }

  final Ref ref;
  final String? groupId;
  final UserServiceFacade _userServiceFacade;
  final GroupMembershipFacade _memberFacade;
  final ValidatorController _validator;

  final TextEditingController accountIdController = TextEditingController();
  UserProfile? user;
  String? username;
  String? userImage;
  String? userDescription;
  Set<String> addedMemberIds = {};

  void setMemberState() {
    final accountId = accountIdController.text;
    addedMemberIds.add(accountId);
  }

  void _init() {
    accountIdController.addListener(() {
      _onAccountIdChanged(groupId);
    });
  }

  Future<void> _onAccountIdChanged(String? groupId) async {
    final validationError = _validateAccountId();
    if (validationError != null) {
      state = null;
    }

    await _memberAddController(groupId);
  }

  String? _validateAccountId() {
    final accountId = accountIdController.text;
    return _validator.validateAccountId(accountId);
  }

  Future<void> _memberAddController(String? groupId) async {
    final authFacade = ref.read(authFacadeProvider);
    final userId = await authFacade.fetchCurrentUserId();
    final myAccount = await _userServiceFacade.fetchUserProfile(userId);
    final accountId = accountIdController.text;
    user = await _userServiceFacade.fetchUserProfileWithAccountId(accountId);

    // アカウントIDが見つからない場合は、nullを返す。
    if (user == null) {
      state = null;
      return;
    }

    // 自分のアカウントを検索した場合は、何も返さない。
    if (myAccount == null || myAccount.accountId == user!.accountId) {
      state = null;
      return;
    }

    // 既にGroup memberの場合は何も返さない。
    if (groupId != null) {
      await _noReturnIfUserIsMember(accountId);
      return;
    }

    // 既に追加済みのメンバーの場合は何も返さない。
    if (addedMemberIds.contains(accountId)) {
      state = null;
      return;
    }

    _setUserProfile();
  }

  Future<void> _noReturnIfUserIsMember(String accountId) async {
    final userId =
        await _userServiceFacade.fetchUserDocIdWithAccountId(accountId);
    final isAlreadyMember =
        await _memberFacade.doesMemberExist(groupId!, userId);

    if (isAlreadyMember) {
      state = null;
    }
  }

  void _setUserProfile() {
    username = user!.name;
    userImage = user!.image;
    userDescription = user!.description;
    state = user;
    return;
  }
}
