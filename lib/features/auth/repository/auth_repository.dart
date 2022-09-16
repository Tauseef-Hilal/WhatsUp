import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/shared/models/user.dart' as user_modal;
import 'package:whatsapp_clone/shared/utils/snackbars.dart';

// GET RID OF BuildContext!

abstract class FirebaseAuthRepository {
  Future<bool> verifyOtp(
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

  Future<bool> registerUser(String username, String avatarUrl) async {
    String uid = auth.currentUser!.uid;
    String phoneNumber = auth.currentUser!.phoneNumber!;

    try {
      await firestore.collection('users').doc(uid).set(
            user_modal.User(
              id: uid,
              name: username,
              avatarUrl: avatarUrl,
              phoneNumber: phoneNumber,
              groupIds: [],
            ).toMap(),
          );
    } on FirebaseException {
      return false;
    }

    return true;
  }
}
