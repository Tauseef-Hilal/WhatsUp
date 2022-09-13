import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/features/auth/views/user_profile.dart';

final verificationControllerProvider =
    StateNotifierProvider.autoDispose<VerificationController, int>(
  (ref) => VerificationController(ref),
);

const _resendFactor = 5;
const _resendInitial = 60;

class VerificationController extends StateNotifier<int> {
  VerificationController(this.ref) : super(60);

  AutoDisposeStateNotifierProviderRef ref;
  int _resendCount = 1;

  late Timer _resendTimer;
  late String _verificationCode;

  void init() {
    _verificationCode = ref.read(verificationCodeProvider);
    updateTimer();
  }

  @override
  void dispose() {
    if (_resendTimer.isActive) _resendTimer.cancel();
    super.dispose();
  }

  bool get isTimerActive => _resendTimer.isActive;

  void updateVerificationCode(String verificationCode) {
    _verificationCode = verificationCode;
  }

  void updateTimer() {
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state == 0) {
        timer.cancel();
        state = _resendCount * _resendInitial * _resendFactor;
      } else {
        state -= 1;
      }
    });

    _resendCount++;
  }

  void onResendPressed(BuildContext context, String phoneNumber) async {
    final authController = ref.read(
      authControllerProvider,
    );

    await authController.sendVerificationCode(
      context,
      phoneNumber,
    );
  }

  void onFilled(BuildContext context, String smsCode) async {
    final authController = ref.read(authControllerProvider);

    await authController.verifyOtp(
      context,
      _verificationCode,
      smsCode,
      () => Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const UserProfileCreationPage(),
        ),
        (route) => false,
      ),
    );
  }
}
