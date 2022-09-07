import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/theme/colors.dart';

class VerificationPage extends ConsumerStatefulWidget {
  final String verificationID;

  const VerificationPage({super.key, required this.verificationID});

  @override
  ConsumerState<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends ConsumerState<VerificationPage> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _otpController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifying your number'),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text('We have sent an SMS with a code.'),
            const SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.50,
              child: TextField(
                onChanged: (value) async {
                  if (value.length == 6) {
                    await authController.verifyOtp(
                      context,
                      widget.verificationID,
                      value,
                    );
                  }
                },
                style: const TextStyle(
                  letterSpacing: 12.0,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
                keyboardType: TextInputType.number,
                cursorColor: AppColors.tabColor,
                controller: _otpController,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: '------',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.tabColor),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
