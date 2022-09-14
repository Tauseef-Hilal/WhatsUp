import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/shared/utils/snackbars.dart';

// GET RID OF BuildContext!

abstract class FirebaseAuthRepository {
  Future<Map<String, String>> verifyOtp(
    String verificationID,
    String smsCode,
  );

  Future<void> signInWithPhone(
    BuildContext context,
    ProviderRef ref,
    String phoneNumber,
  );
}

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
});

class AuthRepository implements FirebaseAuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  const AuthRepository({
    required this.auth,
    required this.firestore,
  });

  @override
  Future<Map<String, String>> verifyOtp(
    String verificationID,
    String smsCode,
  ) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationID,
      smsCode: smsCode,
    );

    final Map<String, String> res =
        await auth.signInWithCredential(credential).then((_) {
      return {'status': 'verified', 'msg': 'Verification complete'};
    }).catchError((error) {
      const Map<String, String> messages = {
        'invalid-verification-code': 'Invalid OTP!',
        'network-request-failed': 'Network error!'
      };

      String? errorMsg;
      if (error.runtimeType == FirebaseAuthException) {
        errorMsg = messages[error.code];
      }

      return {'status': 'failed', 'msg': errorMsg ?? 'Unknown error occured'};
    });

    return res;
  }

  @override
  Future<void> signInWithPhone(
    BuildContext context,
    ProviderRef ref,
    String phoneNumber,
  ) async {
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        // NOT IMPLEMENTED YET
        ref.read(verificationCodeProvider.notifier).state =
            credential.verificationId!;
      },
      verificationFailed: (FirebaseAuthException e) {
        showSnackBar(
          context: context,
          content: e.message!,
          type: SnacBarType.error,
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        ref.read(verificationCodeProvider.notifier).state = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }
}
