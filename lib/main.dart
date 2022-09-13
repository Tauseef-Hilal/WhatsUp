import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:whatsapp_clone/theme/colors.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme/dark.dart';
import 'features/auth/views/welcome.dart' show WelcomePage;

class WhatsApp extends StatelessWidget {
  const WhatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: darkTheme,
      debugShowCheckedModeBanner: false,
      home: const WelcomePage(),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(150),
                color: AppColors.appBarColor,
              ),
              child: Icon(
                Icons.error,
                color: Colors.red[400],
                size: 100,
              ),
            ),
            const SizedBox(
              height: 100,
            ),
            Text(
              details.summary.toString(),
              style: const TextStyle(fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
          ],
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
