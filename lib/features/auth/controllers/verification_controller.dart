import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/domain/auth_service.dart';
import 'package:whatsapp_clone/features/auth/views/user_details.dart';

import 'package:whatsapp_clone/theme/theme.dart';

import '../../../shared/models/user.dart';

const _resendFactor = 5;
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

  int get resendCount => _resendCount;

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

final verificationControllerProvider = Provider<VerificationController>(
  (ref) => VerificationController(ref),
);

class VerificationController {
  VerificationController(this.ref);

  ProviderRef ref;
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

  void onFilled(BuildContext context, String smsCode, Phone phone) async {
    final authController = ref.read(authControllerProvider);
    final colorTheme = Theme.of(context).custom.colorTheme;

    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return FutureBuilder<void>(
            future: authController.verifyOtp(_verificationCode, smsCode),
            builder: (context, snapshot) {
              String? text;
              Widget? widget;

              if (snapshot.hasData) {
                text = 'Verification complete';
                widget = Icon(
                  Icons.check_circle,
                  color: colorTheme.greenColor,
                  size: 38.0,
                );

                Future.delayed(const Duration(seconds: 2), () {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => UserProfileCreationPage(
                          phone: phone,
                        ),
                      ),
                      (route) => false);
                });
              } else if (snapshot.hasError) {
                text = 'Oops! an error occured';

                if (snapshot.error.runtimeType == FirebaseAuthException) {
                  final FirebaseAuthException error =
                      snapshot.error as FirebaseAuthException;

                  final msgs = {
                    'invalid-verification-code': 'Invalid OTP!',
                    'network-request-failed': 'Network error!'
                  };

                  if (msgs.containsKey(error.code)) {
                    text = msgs[error.code];
                  }
                }

                widget = Icon(
                  Icons.cancel,
                  color: colorTheme.errorSnackBarColor,
                  size: 38.0,
                );

                Future.delayed(const Duration(seconds: 2), () {
                  Navigator.of(context).pop();
                });
              }

              return AlertDialog(
                actionsPadding: const EdgeInsets.all(0),
                content: Row(
                  children: [
                    widget ??
                        CircularProgressIndicator(
                          color: colorTheme.greenColor,
                        ),
                    const SizedBox(
                      width: 24.0,
                    ),
                    Text(
                      text ?? 'Connecting',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(fontSize: 16.0),
                    ),
                  ],
                ),
              );
            });
      },
    );
  }
}
