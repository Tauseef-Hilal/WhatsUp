import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/domain/auth_service.dart';
import 'package:whatsapp_clone/features/auth/views/user_details.dart';
import 'package:whatsapp_clone/shared/utils/shared_pref.dart';

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
  Timer _resendTimer = Timer(Duration.zero, () {});
  int get resendCount => _resendCount;

  @override
  void dispose() {
    if (_resendTimer.isActive) {
      _resendTimer.cancel();
    }
    super.dispose();
  }

  bool get isTimerActive => _resendTimer.isActive;

  void updateTimer([bool saveTimestamp = true]) {
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state == 0) {
        timer.cancel();
        state = _resendCount * _resendInitial * _resendFactor;
      } else {
        state -= 1;
      }
    });

    if (saveTimestamp) {
      SharedPref.instance
        ..setInt('resendTime', state)
        ..setString(
          'resendTimestamp',
          DateTime.now().millisecondsSinceEpoch.toString(),
        );

      _resendCount++;
    }
  }

  void setState(int time) {
    state = time;
  }

  void setCount(int count) {
    _resendCount = count;
  }
}

final verificationControllerProvider = Provider<VerificationController>(
  (ref) => VerificationController(ref),
);

class VerificationController {
  VerificationController(this.ref);

  ProviderRef ref;
  late String _verificationCode;

  void init(BuildContext context, String phoneNumber) async {
    final resendTime = SharedPref.instance.getInt('resendTime');
    final resendTimestamp =
        int.parse(SharedPref.instance.getString('resendTimestamp') ?? '0') ~/
            1000;
    final elapsedTime =
        DateTime.now().millisecondsSinceEpoch ~/ 1000 - resendTimestamp;
    final remainingTime = (resendTime ?? 0) - elapsedTime;

    if (resendTime == null || remainingTime < 1) {
      if (resendTime != null && elapsedTime < 3600) {
        int count = resendTime ~/ (_resendFactor * _resendInitial) + 1;

        ref.read(resendTimerControllerProvider.notifier)
          ..setCount(count)
          ..setState(count * _resendFactor * _resendInitial);
      } else {
        ref.read(resendTimerControllerProvider.notifier)
          ..setCount(1)
          ..setState(_resendInitial);
      }

      await sendVerificationCode(context, phoneNumber);
      return;
    }

    int count = resendTime ~/ (_resendFactor * _resendInitial) + 1;

    ref.read(resendTimerControllerProvider.notifier)
      ..setState(remainingTime)
      ..setCount(count)
      ..updateTimer(false);
  }

  void updateVerificationCode(String verificationCode) {
    _verificationCode = verificationCode;
    ref.read(resendTimerControllerProvider.notifier).updateTimer();
  }

  void onResendPressed(BuildContext context, String phoneNumber) async {
    await sendVerificationCode(context, phoneNumber);
  }

  Future<void> sendVerificationCode(
    BuildContext context,
    String phoneNumber,
  ) async {
    final colorTheme = Theme.of(context).custom.colorTheme;

    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return FutureBuilder<void>(future: () async {
          final authController = ref.read(
            authControllerProvider,
          );

          await authController.sendVerificationCode(
            context,
            phoneNumber,
            updateVerificationCode,
          );
        }(), builder: (context, snapshot) {
          String? text;
          Widget? widget;

          if (snapshot.hasError) {
            text = 'Oops! an error occured';
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
                  SharedPref.instance.setInt(
                    'resendTime',
                    0,
                  );
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
