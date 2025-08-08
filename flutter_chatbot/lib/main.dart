// --- START OF FILE main.dart ---

import 'package:flutter/material.dart';
import 'package:flutter_chatbot/core/app_theme.dart';
import 'package:flutter_chatbot/presentation/providers/theme_provider.dart';
import 'package:flutter_chatbot/presentation/screens/chat_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart'; // --- NEW
import 'firebase_options.dart'; // --- NEW (will be generated)

void main() async { // --- MODIFIED: Make main async
  WidgetsFlutterBinding.ensureInitialized(); // --- NEW
  await Firebase.initializeApp( // --- NEW
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Daily Bot',
      localizationsDelegates: const [
        FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
      ],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: const ChatScreen(),
    );
  }
}
// --- END OF FILE main.dart ---