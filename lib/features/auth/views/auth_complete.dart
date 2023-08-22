import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/shared/models/user.dart';
import 'package:whatsapp_clone/features/home/views/base.dart';
import 'package:whatsapp_clone/shared/utils/shared_pref.dart';
import 'package:whatsapp_clone/theme/theme.dart';

class AuthCompletePage extends ConsumerStatefulWidget {
  final User user;

  const AuthCompletePage({
    super.key,
    required this.user,
  });

  @override
  ConsumerState<AuthCompletePage> createState() => _AuthCompletePageState();
}

class _AuthCompletePageState extends ConsumerState<AuthCompletePage> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2), () async {
      final userString = jsonEncode(widget.user.toMap());
      SharedPref.instance.setString("user", userString);

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomePage(user: widget.user)),
          (route) => false);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).custom.colorTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                'Initialising',
                style: TextStyle(
                  fontSize: 20,
                  color: colorTheme.textColor2,
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                'Please wait a moment',
                style: TextStyle(color: colorTheme.greyColor),
              ),
              Expanded(
                child: Image.asset(
                  'assets/images/landing_img.png',
                  color: colorTheme.greenColor,
                  width: 275,
                  height: 300,
                ),
              ),
              CircularProgressIndicator(
                color: colorTheme.greenColor,
              ),
              const SizedBox(height: 32.0),
            ],
          ),
        ),
      ),
    );
  }
}
