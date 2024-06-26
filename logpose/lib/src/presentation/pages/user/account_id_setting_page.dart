import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../components/components/accouunt_id_setting/account_id_save_button.dart';
import '../../components/components/accouunt_id_setting/account_id_section.dart';
import '../../components/components/navigation_bar/account_id_setting_navigation/account_id_setting_navigation_bar.dart';

import '../../notifiers/user_profile_notifier.dart';

class AccountIdSettingPage extends ConsumerStatefulWidget {
  const AccountIdSettingPage({super.key});
  @override
  ConsumerState<AccountIdSettingPage> createState() =>
      AccountIdSettingPageState();
}

class AccountIdSettingPageState extends ConsumerState<AccountIdSettingPage> {
  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileNotifierProvider);
    if (userProfile == null) {
      return const SizedBox.shrink();
    }

    return CupertinoPageScaffold(
      backgroundColor: const Color.fromARGB(255, 245, 243, 254),
      navigationBar: const AccountIdSettingNavigationBar(),
      child: Center(
        child: Column(
          children: [
            AccountIdSection(accountId: userProfile.accountId),
            const AccountIdSaveButton(),
          ],
        ),
      ),
    );
  }
}
