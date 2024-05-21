import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/facade/group_membership_facade.dart';

import '../../../entity/user_profile.dart';

final listenGroupMemberProfileListProvider =
    StreamProvider.family<List<UserProfile?>, String>((ref, groupId) {
  final memberFacade = ref.read(groupMembershipFacadeProvider);
  
  return memberFacade.listenAllMember(groupId);
});
