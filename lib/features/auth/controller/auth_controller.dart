import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/repository/auth_repository.dart';
import 'package:whatsapp_clone/features/auth/views/user_profile.dart';
import 'package:whatsapp_clone/features/auth/views/verification.dart';
import 'package:whatsapp_clone/shared/utils/snackbars.dart';

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

    showSnackBar(
      context: context,
      content: "OTP Sent!",
      type: SnacBarType.info,
    );
  }

  void _navigateToUserCreationPage(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const UserProfileCreationPage(),
      ),
      (route) => false,
    );
  }

  Future<void> verifyOtp(
    BuildContext context,
    String verificationID,
    String smsCode,
  ) async {
    await authRepository.verifyOtp(
      context,
      verificationID,
      smsCode,
      _navigateToUserCreationPage,
    );
  }

  Future<void> signInWithPhone(
    BuildContext context,
    String phoneNumber,
  ) async {
    await authRepository.signInWithPhone(
      context,
      phoneNumber,
      _navigateToVerificationPage,
      _navigateToUserCreationPage,
    );
  }
}
