import 'package:flutter/material.dart';

import 'theme/dark.dart';
import 'views/home.dart' show HomePage;

class WhatsApp extends StatelessWidget {
  const WhatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: darkTheme,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

void main() => runApp(const WhatsApp());
