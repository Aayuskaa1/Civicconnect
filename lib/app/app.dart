import 'package:flutter/material.dart';
import 'package:civic_connect/app/theme/app_theme.dart';
import 'package:civic_connect/features/splash/presentation/pages/splash_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Civic Connect',
      debugShowCheckedModeBanner: false,
      theme: getApplicationTheme(),
      home: const SplashView(),
    );
  }
}