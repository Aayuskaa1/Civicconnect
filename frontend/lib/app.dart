import 'package:flutter/material.dart';
import 'package:civic_connect/app/theme/my_theme.dart';
import 'package:civic_connect/core/api/api_client.dart';
import 'package:civic_connect/features/splash/presentation/pages/splash_view.dart';
import 'package:civic_connect/features/onboarding/presentation/pages/on_boarding_view.dart';
import 'package:civic_connect/features/auth/presentation/pages/login_view.dart';
import 'package:civic_connect/features/auth/presentation/pages/signup_view.dart';
import 'package:civic_connect/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:civic_connect/features/dashboard/presentation/pages/edit_profile_screen.dart';
import 'package:civic_connect/features/reports/presentation/pages/submit_report_view.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: MyTheme.themeData,
      navigatorKey: globalNavigatorKey,
      home: const SplashView(),
      routes: {
        '/onboarding': (_) => const OnBoardingView(),
        '/login': (_) => const LoginView(),
        '/signup': (_) => const SignupView(),
        '/dashboard': (_) => const DashboardScreen(),
        EditProfileScreen.routeName: (_) => const EditProfileScreen(),
        '/submit-report': (_) => const SubmitReportView(),
      },
    );
  }
}
