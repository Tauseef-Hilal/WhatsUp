import 'dart:async';

import 'package:flutter/material.dart';
import 'package:whatsapp_clone/theme/colors.dart';
import 'package:whatsapp_clone/views/home.dart';

class AuthCompletePage extends StatefulWidget {
  const AuthCompletePage({super.key});

  @override
  State<AuthCompletePage> createState() => _AuthCompletePageState();
}

class _AuthCompletePageState extends State<AuthCompletePage> {
  @override
  void initState() {
    Timer(const Duration(seconds: 2), (() {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: ((context) => const HomePage())),
          (route) => false);
    }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Initialising',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.welcomeTitleColor,
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                'Please wait a moment',
                style: Theme.of(context).textTheme.caption,
              ),
              Expanded(
                child: Image.asset(
                  'assets/images/landing_img.png',
                  color: AppColors.tabColor,
                  width: 275,
                  height: 300,
                ),
              ),
              const CircularProgressIndicator(
                color: AppColors.tabColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
