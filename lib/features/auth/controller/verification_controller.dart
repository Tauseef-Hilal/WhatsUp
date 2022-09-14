import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/features/auth/views/user_profile.dart';

const _resendFactor = 1;
const _resendInitial = 60;

final resendTimerControllerProvider =
    AutoDisposeStateNotifierProvider<ResendTimerController, int>(
  (ref) => ResendTimerController(ref),
);

class ResendTimerController extends StateNotifier<int> {
  ResendTimerController(this.ref) : super(_resendInitial);

  AutoDisposeStateNotifierProviderRef ref;
  int _resendCount = 1;

  late Timer _resendTimer;

  void init() {
    updateTimer();
  }

  @override
  void dispose() {
    if (_resendTimer.isActive) _resendTimer.cancel();
    super.dispose();
  }

  bool get isTimerActive => _resendTimer.isActive;

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
}

final verificationControllerProvider = AutoDisposeStateNotifierProvider<
    VerificationController, Map<String, String>>(
  (ref) => VerificationController(ref),
);

const _verificationResponseInitial = {'code': '0', 'msg': 'Verifying OTP'};

class VerificationController extends StateNotifier<Map<String, String>> {
  VerificationController(this.ref) : super(_verificationResponseInitial);

  AutoDisposeStateNotifierProviderRef ref;
  late String _verificationCode;

  void init() {
    _verificationCode = ref.read(verificationCodeProvider);
  }

  void updateVerificationCode(String verificationCode) {
    _verificationCode = verificationCode;
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
    state = _verificationResponseInitial;

    final authController = ref.read(authControllerProvider);

    final Map<String, String> res = await authController.verifyOtp(
      _verificationCode,
      smsCode,
    );

    if (res['status'] == 'failed') {
      // ignore: use_build_context_synchronously
      _onVerificationFailed(context, res['msg']!);
    } else {
      // ignore: use_build_context_synchronously
      _onVerificationComplete(context, res['msg']!);
    }
  }

  void _onVerificationFailed(BuildContext context, String errorMsg) async {
    state = {'code': '-1', 'msg': errorMsg};

    await Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }

  void _onVerificationComplete(BuildContext context, String msg) async {
    state = {'code': '1', 'msg': msg};

    await Future.delayed(const Duration(seconds: 1), (() {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const UserProfileCreationPage(),
        ),
        (route) => false,
      );
    }));
  }
}
