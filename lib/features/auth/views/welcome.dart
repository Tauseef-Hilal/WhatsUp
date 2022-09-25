import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/auth/views/login.dart';
import 'package:whatsapp_clone/shared/widgets/buttons.dart';
import 'package:whatsapp_clone/theme/colors.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  void _navigateToLoginPage(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (builder) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            const Text(
              'Welcome to WhatsApp',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor2,
              ),
            ),
            Expanded(
              child: Image.asset(
                'assets/images/landing_img.png',
                color: AppColors.greenColor,
                width: 275,
                height: 300,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(context).textTheme.caption,
                  children: const [
                    TextSpan(text: 'Read our '),
                    TextSpan(
                      text: 'Privacy Policy. ',
                      style: TextStyle(color: AppColors.blueColor),
                    ),
                    TextSpan(text: 'Tap "Agree and Continue" to accept the'),
                    TextSpan(
                      text: ' Terms of Service.',
                      style: TextStyle(color: AppColors.blueColor),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 70,
                vertical: 25,
              ),
              child: GreenElevatedButton(
                onPressed: () => _navigateToLoginPage(context),
                text: 'AGREE AND CONTINUE',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
