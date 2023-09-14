import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/data/repositories/auth_repository.dart';
import 'package:whatsapp_clone/shared/models/user.dart';
import 'package:whatsapp_clone/shared/repositories/firebase_storage.dart';

final authControllerProvider = Provider((ref) {
  return AuthController(ref: ref);
});

final verificationCodeProvider = StateProvider((ref) => '');

class AuthController {
  final ProviderRef ref;
  final FirebaseAuthRepository authRepository;

  AuthController({required this.ref})
      : authRepository = ref.watch(authRepositoryProvider);

  Future<bool> verifyOtp(
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
    void Function(String code) onCodeSent,
  ) async {
    await authRepository.signInWithPhone(
      context,
      ref,
      phoneNumber,
      onCodeSent,
    );
  }

  Future<User> saveUserData(
    BuildContext context,
    WidgetRef ref,
    String username,
    Phone phone,
    File? avatar,
  ) async {
    String uid = authRepository.auth.currentUser!.uid;
    String avatarUrl =
        'https://en.gravatar.com/userimage/238463648/8cc16f6f5423605920569a634fd097eb.jpeg?size=256';

    if (avatar != null) {
      final task = await ref
          .read(firebaseStorageRepoProvider)
          .uploadFileToFirebase(avatar, 'userAvatars/$uid');
      avatarUrl = await (await task).ref.getDownloadURL();
    }

    final user = User(
      id: uid,
      name: username,
      avatarUrl: avatarUrl,
      phone: phone,
      activityStatus: UserActivityStatus.online,
    );

    await authRepository.registerUser(user.toMap());
    return user;
  }
}
