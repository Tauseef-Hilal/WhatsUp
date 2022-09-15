import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:whatsapp_clone/features/auth/views/user_details.dart';
import 'firebase_options.dart';

import 'package:whatsapp_clone/theme/colors.dart';
import 'package:whatsapp_clone/theme/dark.dart';

class WhatsApp extends StatelessWidget {
  const WhatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: darkTheme,
      debugShowCheckedModeBanner: false,
      home: const UserProfileCreationPage(),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  ErrorWidget.builder = (details) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 25,
              ),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(150),
                  color: AppColors.appBarColor,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red[400],
                  size: 50,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.appBarColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                      ),
                      child: ListView(
                        children: [
                          const SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            'OOPS!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Colors.red[400],
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            details.toString(),
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: AppColors.linkColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  };

  runApp(
    const ProviderScope(
      child: WhatsApp(),
    ),
  );
}
