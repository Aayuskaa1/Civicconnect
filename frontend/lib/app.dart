import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/app/theme/my_theme.dart';
import 'package:civic_connect/core/api/api_client.dart';
import 'package:civic_connect/features/splash/presentation/pages/splash_view.dart';
import 'package:civic_connect/features/onboarding/presentation/pages/on_boarding_view.dart';
import 'package:civic_connect/features/auth/presentation/pages/login_view.dart';
import 'package:civic_connect/features/auth/presentation/pages/signup_view.dart';
import 'package:civic_connect/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:civic_connect/features/dashboard/presentation/pages/edit_profile_screen.dart';
import 'package:civic_connect/features/reports/presentation/pages/submit_report_view.dart';
import 'package:civic_connect/features/sensors/presentation/view_model/sensor_controller.dart';

class App extends ConsumerWidget {
  const App({super.key});

  ThemeMode _resolveThemeMode(String? ambient) {
    switch (ambient) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ambient = ref.watch(
      sensorControllerProvider.select((s) => s.ambientThemeMode),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: MyTheme.lightTheme,
      darkTheme: MyTheme.darkTheme,
      themeMode: _resolveThemeMode(ambient),
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
