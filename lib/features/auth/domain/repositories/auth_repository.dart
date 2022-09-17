import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class AuthenticationRepository {
  Future<bool> verifyOtp(
    String verificationID,
    String smsCode,
  );

  Future<void> signInWithPhone(
    BuildContext context,
    ProviderRef ref,
    String phoneNumber,
  );

  Future<bool> registerUser(Map<String, dynamic> userData);
}
