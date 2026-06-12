import 'package:flutter/material.dart';
import 'package:civic_connect/features/splash/presentation/pages/splash_page.dart';
import 'package:civic_connect/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:civic_connect/features/auth/presentation/pages/login_page.dart';
import 'package:civic_connect/features/auth/presentation/pages/signup_page.dart';
import 'package:civic_connect/features/dashboard/presentation/pages/dashboard_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const SplashPage(),
      routes: {
        '/onboarding': (_) => const OnboardingPage(),
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignupPage(),
        '/dashboard': (_) => const DashboardPage(),
      },
    );
  }
}
