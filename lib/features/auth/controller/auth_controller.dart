import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/repository/auth_repository.dart';
import 'package:whatsapp_clone/shared/repositories/shared_firebase_repo.dart';

final authControllerProvider = Provider((ref) {
  return AuthController(ref: ref);
});

final verificationCodeProvider = StateProvider((ref) => '');

class AuthController {
  final ProviderRef ref;
  final AuthRepository authRepository;

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
  ) async {
    phoneNumber = phoneNumber
        .replaceAll('-', ' ')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll(' ', '');

    await authRepository.signInWithPhone(context, ref, phoneNumber);
  }

  Future<bool> saveUserData(
    BuildContext context,
    WidgetRef ref,
    String username,
    File? avatar,
  ) async {
    String uid = authRepository.auth.currentUser!.uid;
    String avatarUrl = "http://www.gravatar.com/avatar/?d=mp";

    if (avatar != null) {
      avatarUrl = await ref
          .read(sharedFirebaseRepoProvider)
          .uploadFileToFirebase(avatar, 'userAvatars/$uid');
    }

    await authRepository.registerUser(username, avatarUrl);
    return true;
    
  }
}
