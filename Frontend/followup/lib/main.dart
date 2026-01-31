import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/events_provider.dart';
// import 'pages/landing_page.dart'; // Hidden for now
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/chat_page.dart';
import 'pages/input_page.dart';
import 'pages/preview_page.dart';
import 'pages/events_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const FollowUpApp());
}

class FollowUpApp extends StatelessWidget {
  const FollowUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => EventsProvider()),
      ],
      child: MaterialApp(
        title: 'FollowUP',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        // Localization support
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English (default)
          Locale('zh'), // Chinese
          Locale('de'), // German
        ],
        locale: const Locale('en'), // Default to English
        initialRoute: '/',
        onGenerateRoute: (settings) {
          // Route generator for passing arguments
          switch (settings.name) {
            case '/':
              // Start with login page
              return MaterialPageRoute(
                builder: (_) => const LoginPage(),
              );
            case '/login':
              return MaterialPageRoute(
                builder: (_) => const LoginPage(),
              );
            case '/chat':
              // New AI chat page (main page after login)
              return MaterialPageRoute(
                builder: (_) => const ChatPage(),
              );
            case '/home':
              // Legacy home page (kept for compatibility)
              return MaterialPageRoute(
                builder: (_) => const HomePage(),
              );
            case '/input':
              return MaterialPageRoute(
                builder: (_) => const InputPage(),
                settings: settings,
              );
            case '/preview':
              return MaterialPageRoute(
                builder: (_) => const PreviewPage(),
                settings: settings,
              );
            case '/events':
              return MaterialPageRoute(
                builder: (_) => const EventsPage(),
              );
            default:
              return MaterialPageRoute(
                builder: (_) => const LoginPage(),
              );
          }
        },
      ),
    );
  }
}
