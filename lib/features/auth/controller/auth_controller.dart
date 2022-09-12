import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/repository/auth_repository.dart';

final authControllerProvider = Provider((ref) {
  return AuthController(ref: ref);
});

final verificationCodeProvider = StateProvider((ref) => '');

class AuthController {
  final ProviderRef ref;
  final AuthRepository authRepository;

  AuthController({required this.ref})
      : authRepository = ref.watch(authRepositoryProvider);

  Future<void> verifyOtp(
    BuildContext context,
    String verificationID,
    String smsCode,
    VoidCallback onVerified,
  ) async {
    await authRepository.verifyOtp(
      context,
      verificationID,
      smsCode,
      onVerified,
    );
  }

  Future<void> sendVerificationCode(
    BuildContext context,
    String phoneNumber,
  ) async {
    phoneNumber = phoneNumber
        .replaceAll('-', ' ')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll(' ', '');

    await authRepository.signInWithPhone(context, ref, phoneNumber);
  }
}
