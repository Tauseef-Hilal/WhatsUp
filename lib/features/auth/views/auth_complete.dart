import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/shared/models/user.dart';
import 'package:whatsapp_clone/features/home/views/base.dart';
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
  late Timer _timer;

  @override
  void initState() {
    _timer = Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomePage(user: widget.user)),
          (route) => false);
    });

    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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
                  fontSize: 18,
                  color: colorTheme.textColor2,
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                'Please wait a moment',
                style: Theme.of(context).textTheme.bodySmall,
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
              const SizedBox(height: 12.0),
            ],
          ),
        ),
      ),
    );
  }
}
