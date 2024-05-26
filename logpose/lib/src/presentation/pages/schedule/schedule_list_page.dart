import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../components/common/bottom_gradation.dart';

import '../../components/components/schedule_list/schedule_card_list.dart';
import '../../components/components/schedule_list/schedule_creation_button.dart';
import '../../components/components/schedule_list/schedule_sort_button.dart';

import '../../providers/group/group/listen_is_joined_group_exist_provider.dart';

class ScheduleListPage extends ConsumerStatefulWidget {
  const ScheduleListPage({super.key});
  @override
  ConsumerState createState() => _ScheduleListState();
}

class _ScheduleListState extends ConsumerState<ScheduleListPage> {
  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    final isJoinedGroupExist = ref.watch(listenIsJoinedGroupExistProvider);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF5F3FE),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Positioned(
            top: deviceHeight * 0.13,
            right: deviceWidth * 0.1,
            child: const ScheduleSortButton(),
          ),
          Positioned(
            top: deviceHeight * 0.173,
            child: const ScheduleCardList(),
          ),
          const Positioned(
            bottom: 0,
            child: BottomGradation(),
          ),
          if (isJoinedGroupExist is AsyncLoading)
            const Center(child: CupertinoActivityIndicator()),
          if (isJoinedGroupExist is AsyncError)
            Center(child: Text('Error: ${isJoinedGroupExist.error}')),

          // グループが存在する場合のみボタンを表示
          if (isJoinedGroupExist is AsyncData &&
              isJoinedGroupExist.value == true)
            Positioned(
              top: deviceHeight * 0.875,
              child: const ScheduleCreationButton(),
            ),
        ],
      ),
    );
  }
}
