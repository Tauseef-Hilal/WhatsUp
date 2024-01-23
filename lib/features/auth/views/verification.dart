import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/domain/auth_service.dart';
import 'package:whatsapp_clone/features/auth/controllers/verification_controller.dart';
import 'package:whatsapp_clone/features/auth/views/login.dart';

import 'package:whatsapp_clone/shared/utils/abc.dart';
import 'package:whatsapp_clone/shared/utils/snackbars.dart';
import 'package:whatsapp_clone/theme/theme.dart';

import '../../../shared/models/user.dart';

class VerificationPage extends ConsumerStatefulWidget {
  final Phone phone;

  const VerificationPage({
    super.key,
    required this.phone,
  });

  @override
  ConsumerState<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends ConsumerState<VerificationPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(verificationControllerProvider).init(
            context,
            widget.phone.rawNumber,
          );
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(verificationCodeProvider, (previous, next) {
      showSnackBar(
        context: context,
        content: 'OTP sent!',
        type: SnacBarType.info,
      );

      ref.read(verificationControllerProvider).updateVerificationCode(next);
      ref.read(resendTimerControllerProvider.notifier).updateTimer();
    });

    final resendTime = ref.watch(resendTimerControllerProvider);
    final colorTheme = Theme.of(context).custom.colorTheme;
    final isTimerActive =
        ref.watch(resendTimerControllerProvider.notifier).isTimerActive;
    final multipleTimesSent =
        ref.read(resendTimerControllerProvider.notifier).resendCount > 2;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Verifying your number',
          style: TextStyle(color: colorTheme.textColor1),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: colorTheme.statusBarColor,
          statusBarIconBrightness:
              Theme.of(context).brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
          systemNavigationBarColor: colorTheme.navigationBarColor,
          systemNavigationBarDividerColor: colorTheme.navigationBarColor,
        ),
        actions: [
          Icon(
            Icons.more_vert_rounded,
            color: colorTheme.greyColor,
          ),
          const SizedBox(width: 16)
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 50.0,
                vertical: 16.0,
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    multipleTimesSent
                        ? TextSpan(
                            text: 'You have tried to register ',
                            style: TextStyle(color: colorTheme.textColor1),
                          )
                        : TextSpan(
                            text:
                                'Waiting to automatically detect an SMS sent to ',
                            style: TextStyle(color: colorTheme.textColor1),
                          ),
                    TextSpan(
                      text: '${widget.phone.formattedNumber}. ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorTheme.textColor1,
                      ),
                    ),
                    if (multipleTimesSent) ...[
                      TextSpan(
                        text:
                            'recently. Wait before requesting an SMS or a call with your code. ',
                        style: TextStyle(color: colorTheme.textColor1),
                      )
                    ],
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                            (route) => false,
                          );
                        },
                      text: 'Wrong Number?',
                      style: TextStyle(color: colorTheme.blueColor),
                    ),
                  ],
                ),
              ),
            ),
            OTPField(
              onFilled: (value) {
                ref
                    .read(verificationControllerProvider)
                    .onFilled(context, value, widget.phone);
              },
            ),
            const SizedBox(
              height: 12,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                'Enter 6-digit code',
                style: TextStyle(color: colorTheme.greyColor),
              ),
            ),
            InkWell(
              onTap: isTimerActive
                  ? null
                  : () =>
                      ref.read(verificationControllerProvider).onResendPressed(
                            context,
                            widget.phone.rawNumber,
                          ),
              child: Text(
                'Didn\'t receive code?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isTimerActive
                      ? colorTheme.greyColor
                      : colorTheme.greenColor,
                ),
              ),
            ),
            Text(
              isTimerActive
                  ? 'You may request a new code in ${timeFromSeconds(resendTime, true)}'
                  : '',
              style: TextStyle(color: colorTheme.greyColor),
            ),
          ],
        ),
      ),
    );
  }
}

class OTPField extends ConsumerStatefulWidget {
  const OTPField({
    super.key,
    required this.onFilled,
  });
  final Function(String value) onFilled;

  @override
  ConsumerState<OTPField> createState() => _OTPFieldState();
}

class _OTPFieldState extends ConsumerState<OTPField> {
  final _textController = TextEditingController();
  final hintText = '––– –––';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  double calculateHintWidth() {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: hintText,
        style: const TextStyle(
          overflow: TextOverflow.fade,
          fontFamily: 'AzeretMono',
          fontSize: 20,
          letterSpacing: 4,
        ),
      ),
      textScaler: MediaQuery.of(context).textScaler,
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    return textPainter.width;
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).custom.colorTheme;
    final hintWidth = calculateHintWidth() + 4;
    final totalWidth = hintWidth + 50;
    final textStyle = TextStyle(
      backgroundColor: colorTheme.backgroundColor,
      fontFamily: "AzeretMono",
      fontSize: 20,
      letterSpacing: 4,
      color: colorTheme.textColor1,
    );

    return Container(
      width: totalWidth,
      height: 44,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 2,
            color: colorTheme.greenColor,
          ),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: hintWidth,
            child: Text(
              hintText,
              maxLines: 1,
              style: textStyle.copyWith(color: colorTheme.greyColor),
            ),
          ),
          SizedBox(
            width: hintWidth,
            child: TextField(
              maxLength: 7,
              autofocus: true,
              onChanged: (value) {
                String newValue = value;
                TextSelection selection = _textController.selection;
                int cursorPosition = selection.baseOffset;

                if (value.length > 3 && !value.contains(' ')) {
                  newValue =
                      '${value.substring(0, 3)} ${value.substring(3, value.length)}';
                  cursorPosition++;
                } else if (value.length == 4 && value.contains(' ')) {
                  newValue = value.substring(0, 3);
                  cursorPosition--;
                }

                _textController.value = TextEditingValue(
                  text: newValue,
                  selection: TextSelection.collapsed(offset: cursorPosition),
                );

                if (newValue.length == 7) {
                  widget.onFilled(newValue.replaceAll(' ', ''));
                  return;
                }
              },
              controller: _textController,
              style: textStyle,
              keyboardType: TextInputType.phone,
              cursorColor: colorTheme.greenColor,
              decoration: InputDecoration(
                counterText: '',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: colorTheme.backgroundColor,
                    width: 0,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 0,
                    color: colorTheme.backgroundColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
