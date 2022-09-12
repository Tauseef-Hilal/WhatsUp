import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/shared/utils/snackbars.dart';

// GET RID OF BuildContext!

abstract class FirebaseAuthRepository {
  Future<void> verifyOtp(
    BuildContext context,
    String verificationID,
    String smsCode,
    Function onVerified,
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
  Future<void> verifyOtp(
    BuildContext context,
    String verificationID,
    String smsCode,
    Function onVerified,
  ) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationID,
      smsCode: smsCode,
    );
    
    await auth.signInWithCredential(credential).then((_) {
      onVerified();
    }).catchError((error) {
      showSnackBar(
        context: context,
        content: error.message!,
        type: SnacBarType.error,
      );
    });
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
