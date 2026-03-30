import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';
import 'app/router.dart';
import 'app/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 환경 변수 로드 (API 키 등)
  await dotenv.load(fileName: '.env');

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const SnippetApp(),
    ),
  );
}

class SnippetApp extends ConsumerWidget {
  const SnippetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Snippet',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
