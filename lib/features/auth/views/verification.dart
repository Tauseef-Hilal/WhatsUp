import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/features/auth/controller/verification_controller.dart';
import 'package:whatsapp_clone/features/auth/views/login.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';
import 'package:whatsapp_clone/shared/utils/snackbars.dart';
import 'package:whatsapp_clone/theme/colors.dart';

class VerificationPage extends ConsumerStatefulWidget {
  final String phoneNumber;

  const VerificationPage({
    super.key,
    required this.phoneNumber,
  });

  @override
  ConsumerState<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends ConsumerState<VerificationPage> {
  final GlobalKey _dialogKey = GlobalKey();
  late String verificationMsg;
  late int verificationResponseCode;
  late final Map<int, Widget> _dialogStatusWidget;

  @override
  void initState() {
    _dialogStatusWidget = {
      -1: const Icon(
        Icons.cancel,
        color: AppColors.errorSnackBarColor,
        size: 38.0,
      ),
      0: const CircularProgressIndicator(
        color: AppColors.tabColor,
      ),
      1: const Icon(
        Icons.verified_rounded,
        color: AppColors.tabColor,
        size: 38.0,
      ),
    };

    final verificationResponse = ref.read(verificationControllerProvider);
    verificationResponseCode = int.parse(verificationResponse['code']!);
    verificationMsg = verificationResponse['msg']!;

    ref.read(verificationControllerProvider.notifier).init();
    ref.read(resendTimerControllerProvider.notifier).init();
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

      ref
          .read(verificationControllerProvider.notifier)
          .updateVerificationCode(next);

      ref.read(resendTimerControllerProvider.notifier).updateTimer();
    });

    ref.listen(verificationControllerProvider, (previous, next) {
      _updateDialog(next);
    });

    final resendTime = ref.watch(resendTimerControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifying your number'),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 30),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Waiting to automatically detect an SMS sent to ',
                    style: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(fontSize: 11.0, color: AppColors.textColor),
                  ),
                  TextSpan(
                    text: '${widget.phoneNumber}.',
                    style: Theme.of(context).textTheme.caption!.copyWith(
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 4.0,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                  (route) => false,
                );
              },
              child: Text(
                'Wrong Number?',
                style: Theme.of(context)
                    .textTheme
                    .caption!
                    .copyWith(fontSize: 11.0, color: AppColors.linkColor),
              ),
            ),
            const SizedBox(height: 8.0),
            OTPField(
              onFilled: (value) {
                _showVerificationDialog(context);
                ref
                    .read(verificationControllerProvider.notifier)
                    .onFilled(context, value);
              },
            ),
            const SizedBox(height: 24.0),
            Text(
              'Enter 6-digit code',
              style: Theme.of(context).textTheme.caption,
            ),
            const SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      TextButton(
                        onPressed: ref
                                .read(resendTimerControllerProvider.notifier)
                                .isTimerActive
                            ? null
                            : () => ref
                                .read(verificationControllerProvider.notifier)
                                .onResendPressed(context, widget.phoneNumber),
                        style: TextButton.styleFrom(
                          textStyle: Theme.of(context).textTheme.caption,
                          alignment: Alignment.centerLeft,
                          foregroundColor: AppColors.tabColor,
                          disabledForegroundColor: AppColors.appBarColor,
                          padding: const EdgeInsets.only(left: 0.0),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.chat_rounded,
                              color: ref
                                      .read(resendTimerControllerProvider
                                          .notifier)
                                      .isTimerActive
                                  ? AppColors.greyColor
                                  : AppColors.tabColor,
                            ),
                            const SizedBox(
                              width: 16.0,
                            ),
                            const Text(
                              'Resend SMS',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    ref
                            .read(resendTimerControllerProvider.notifier)
                            .isTimerActive
                        ? strFormattedTime(resendTime)
                        : '',
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Divider(
                color: AppColors.greyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _showVerificationDialog(BuildContext context) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          key: _dialogKey,
          builder: (context, setState) {
            return AlertDialog(
              actionsPadding: const EdgeInsets.all(0),
              backgroundColor: AppColors.appBarColor,
              content: Row(
                children: [
                  _dialogStatusWidget[verificationResponseCode]!,
                  const SizedBox(
                    width: 24.0,
                  ),
                  Text(
                    verificationMsg,
                    style: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(fontSize: 16.0),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _updateDialog(Map<String, String> response) {
    verificationResponseCode = int.parse(response['code']!);
    verificationMsg = response['msg']!;

    if (_dialogKey.currentState != null && _dialogKey.currentState!.mounted) {
      _dialogKey.currentState!.setState(() {});
    }
  }
}

class OTPField extends StatefulWidget {
  const OTPField({
    super.key,
    required this.onFilled,
    this.autofocus,
    this.textStyle,
    this.decoration,
  });
  final Function(String value) onFilled;
  final bool? autofocus;
  final TextStyle? textStyle;
  final InputDecoration? decoration;

  @override
  State<OTPField> createState() => _OTPFieldState();
}

class _OTPFieldState extends State<OTPField> {
  late final List<FocusNode> _focusNodes;
  late final List<TextField> _textFields;
  late final List<TextEditingController> _fieldControllers;
  String _smsCode = '';

  void onChanged(int index, String value) {
    setState(() {
      if (value.isEmpty) {
        if (index > 0) {
          _focusNodes[index - 1].requestFocus();
        }
      } else {
        if (index < _textFields.length - 1) {
          _focusNodes[index + 1].requestFocus();
        }
      }

      _smsCode = _fieldControllers.map((e) => e.text).join();
      final emptyFieldCount = _fieldControllers.where((field) {
        return field.text.isEmpty;
      }).length;

      if (_smsCode.length == 6 && emptyFieldCount == 0) {
        _textFields[index].onSubmitted!(_smsCode);
      }
    });
  }

  @override
  void initState() {
    _focusNodes = List.generate(6, (index) => FocusNode());
    _fieldControllers = List.generate(6, (index) => TextEditingController());
    _textFields = List.generate(
      6,
      (index) => TextField(
        onChanged: (value) => onChanged(index, value),
        onSubmitted: (value) => widget.onFilled(_smsCode),
        style: widget.textStyle ??
            const TextStyle(
              fontSize: 20.0,
              color: AppColors.textColor,
            ),
        autofocus: widget.autofocus ?? index == 0,
        keyboardType: TextInputType.number,
        decoration: widget.decoration ??
            const InputDecoration(
              hintText: ' -',
              border: InputBorder.none,
            ),
        controller: _fieldControllers[index],
        focusNode: _focusNodes[index],
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    for (var i = 0; i < _textFields.length; i++) {
      _focusNodes[i].dispose();
      _fieldControllers[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.50,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.tabColor,
            width: 2.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var field in _textFields.sublist(0, 3))
                SizedBox(
                  width: 20,
                  child: field,
                )
            ],
          ),
          const SizedBox(
            width: 16.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var field in _textFields.sublist(3))
                SizedBox(
                  width: 20,
                  child: field,
                )
            ],
          ),
        ],
      ),
    );
  }
}
