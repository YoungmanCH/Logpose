// ignore_for_file: use_setters_to_change_properties

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../validation/validator/validator_controller.dart';

import '../navigations/to_email_setting_nex_page_navigator.dart';

import '../providers/error_message/password_error_message_provider.dart';
import '../providers/text_field/password_field_provider.dart';

class MoveToNextPageButtonHandler {
  MoveToNextPageButtonHandler({required this.context, required this.ref});

  final BuildContext context;
  final WidgetRef ref;

  Future<void> handlePassword() async {
    final password = ref.watch(passwordFieldProvider('')).text;

    final errorMessage = _validationPassword(password);
    if (errorMessage != null) {
      _setErrorMessage(errorMessage);
      return;
    }

    await _moveToPage(password);
  }

  String? _validationPassword(String password) {
    final validatorController = ref.read(validatorControllerProvider);
    return validatorController.validatePassword(password);
  }

  void _setErrorMessage(String errorMessage) {
    ref.watch(passwordErrorMessageProvider.notifier).state = errorMessage;
  }

  Future<void> _moveToPage(String password) async {
    if (context.mounted) {
      final navigator = ToEmailSettingNextPageNavigator(context);
      await navigator.moveToPage(password);
    }
  }
}
