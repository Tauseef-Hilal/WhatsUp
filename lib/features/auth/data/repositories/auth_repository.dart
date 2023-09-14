import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/domain/repositories/auth_repository.dart';
import 'package:whatsapp_clone/shared/utils/snackbars.dart';

final authRepositoryProvider = Provider((ref) {
  return FirebaseAuthRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
});

class FirebaseAuthRepository implements AuthenticationRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  const FirebaseAuthRepository({
    required this.auth,
    required this.firestore,
  });

  @override
  Future<bool> verifyOtp(
    String verificationID,
    String smsCode,
  ) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationID,
      smsCode: smsCode,
    );

    return await auth.signInWithCredential(credential).then((_) {
      return true;
    });
  }

  @override
  Future<void> signInWithPhone(
    BuildContext context,
    ProviderRef ref,
    String phoneNumber,
    void Function(String code) onCodeSent,
  ) async {
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        // NOT IMPLEMENTED YET
      },
      verificationFailed: (FirebaseAuthException e) {
        Navigator.pop(context);
        showSnackBar(
          context: context,
          content: e.message!,
          type: SnacBarType.error,
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
        Navigator.pop(context);
        showSnackBar(
          context: context,
          content: "OTP Sent!",
          type: SnacBarType.info,
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Future<bool> registerUser(Map<String, dynamic> userData) async {
    await firestore.collection('users').doc(userData['id']).set(userData);
    return true;
  }
}
