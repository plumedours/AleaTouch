import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const AleaTouchApp());
}

class AleaTouchApp extends StatelessWidget {
  const AleaTouchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AleaTouch',
      theme: ThemeData.dark(),
      home: const SplashScreen(),
    );
  }
}