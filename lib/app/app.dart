import 'package:flutter/material.dart';
// Ensure these paths match your actual project structure
import 'package:civic_connect/app/theme/app_theme.dart'; 
import 'package:civic_connect/features/splash/presentation/pages/splash_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Civic Connect',
      debugShowCheckedModeBanner: false,
      // Access static methods directly via the class name
      theme: AppTheme.lightTheme, 
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashView(),
    );
  }
}