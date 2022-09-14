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

  Future<Map<String, String>> verifyOtp(
    String verificationID,
    String smsCode,
  ) async {
    return await authRepository.verifyOtp(
      verificationID,
      smsCode,
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
