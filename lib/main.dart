import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const ProviderScope(child: SnippetApp()));
}

class SnippetApp extends StatelessWidget {
  const SnippetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snippet',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
