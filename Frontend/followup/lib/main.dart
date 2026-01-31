import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/events_provider.dart';
import 'pages/landing_page.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
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
        themeMode: ThemeMode.light, // 使用浅色主题以匹配温暖米色风格
        initialRoute: '/',
        onGenerateRoute: (settings) {
          // 路由生成器，用于传递参数
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                builder: (_) => const LandingPage(),
              );
            case '/login':
              return MaterialPageRoute(
                builder: (_) => const LoginPage(),
              );
            case '/home':
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
                builder: (_) => const LandingPage(),
              );
          }
        },
      ),
    );
  }
}
