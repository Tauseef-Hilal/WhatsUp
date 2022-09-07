import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/auth/views/login.dart';
import 'package:whatsapp_clone/shared/widgets/buttons.dart';
import 'package:whatsapp_clone/theme/colors.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  void _navigateToLoginPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (builder) => const LoginPage()),
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
                color: AppColors.welcomeTitleColor,
              ),
            ),
            Expanded(
              child: Image.asset(
                'assets/images/landing_img.png',
                color: AppColors.tabColor,
                width: 275,
                height: 300,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Read our Privacy Policy. Tap "Agree and continue" to accept the'
                ' Terms of Service.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.caption,
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
