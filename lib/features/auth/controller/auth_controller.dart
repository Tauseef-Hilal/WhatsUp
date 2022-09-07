import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/repository/auth_repository.dart';
import 'package:whatsapp_clone/features/auth/views/verification.dart';

final authControllerProvider = Provider((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepo);
});

class AuthController {
  final FirebaseAuthRepository authRepository;

  const AuthController({required this.authRepository});

  void _navigateToVerificationPage(
    BuildContext context,
    String verificationID,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return VerificationPage(verificationID: verificationID);
      }),
    );
  }

  void verifyOtp(BuildContext context, String verificationID, String smsCode) {
    authRepository.verifyOtp(context, verificationID, smsCode);
  }

  void signInWithPhone(BuildContext context, String phoneNumber) {
    authRepository.signInWithPhone(
      context,
      phoneNumber,
      _navigateToVerificationPage,
    );
  }
}
