import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/auth/auth_controller.dart';

import '../../../validation/password_validation.dart';

final passwordSettingProvider = Provider.autoDispose<_UserPasswordSetting>(
  (ref) => _UserPasswordSetting(),
);

class _UserPasswordSetting {
  TextEditingController passwordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();

  Future<String?> update() async {
    final validationPasswordError =
        _validationPassword(newPasswordController.text);
    if (validationPasswordError != null) {
      return validationPasswordError;
    }

    // Get user email
    final email = await _readUserEmail();
    if (email == null) {
      return "Failed to read user's email.";
    }

    return _updateUserPassword(email);
  }

  // Validate new password
  String? _validationPassword(String newPassword) {
    final passwordError = PasswordValidation.validation(newPassword);
    if (passwordError != null) {
      return passwordError;
    }
    return null;
  }

  Future<String?> _updateUserPassword(String email) async {
    final newPassword = newPasswordController.text;
    final password = passwordController.text;

    // Attempt to update password
    // Returns null if no error
    try {
      return AuthController.updateUserPassword(
        email,
        password,
        newPassword,
      );
    } on FirebaseException catch (e) {
      return 'Failed to update password: ${e.message}';
    }
  }

  Future<String?> _readUserEmail() async {
    final email = await AuthController.readEmail();
    return email;
  }
}