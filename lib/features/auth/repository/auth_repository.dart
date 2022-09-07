import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/views/user_profile.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';

abstract class FirebaseAuthRepository {
  void verifyOtp(
    BuildContext context,
    String verificationID,
    String smsCode,
  );
  void signInWithPhone(
    BuildContext context,
    String phoneNumber,
    Function onCodeSent,
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

  const AuthRepository({required this.auth, required this.firestore});

  @override
  void verifyOtp(
    BuildContext context,
    String verificationID,
    String smsCode,
  ) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationID,
        smsCode: smsCode,
      );

      await auth.signInWithCredential(credential);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => const UserProfileCreationPage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  @override
  void signInWithPhone(
    BuildContext context,
    String phoneNumber,
    Function onCodeSent,
  ) async {
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const UserProfileCreationPage(),
          ),
          (route) => false,
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        showSnackBar(context, e.toString());
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(context, verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }
}
