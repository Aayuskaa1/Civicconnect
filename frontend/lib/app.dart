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
import 'package:civic_connect/features/sensors/presentation/pages/light_sensor_screen.dart';
import 'package:civic_connect/features/sensors/presentation/pages/sensor_dashboard_screen.dart';
import 'package:civic_connect/features/sensors/presentation/view_model/adaptive_brightness_controller.dart';
import 'package:civic_connect/features/sensors/presentation/view_model/sensor_controller.dart';
import 'package:civic_connect/features/sensors/presentation/widgets/adaptive_brightness_overlay.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep sensors subscribed so shake / light features stay active app-wide.
    ref.watch(sensorControllerProvider);
    final adaptive = ref.watch(adaptiveBrightnessProvider);

    // Adaptive Brightness (iOS): follow system brightness for in-app theme only.
    // Does not change UIScreen.main.brightness.
    final themeMode = (!adaptive.enabled || !adaptive.available)
        ? ThemeMode.light
        : (adaptive.isDarkUi ? ThemeMode.dark : ThemeMode.light);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: MyTheme.lightTheme,
      darkTheme: MyTheme.darkTheme,
      themeMode: themeMode,
      navigatorKey: globalNavigatorKey,
      builder: (context, child) {
        return AdaptiveBrightnessOverlay(
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const SplashView(),
      routes: {
        '/onboarding': (_) => const OnBoardingView(),
        '/login': (_) => const LoginView(),
        '/signup': (_) => const SignupView(),
        '/dashboard': (_) => const DashboardScreen(),
        EditProfileScreen.routeName: (_) => const EditProfileScreen(),
        '/submit-report': (_) => const SubmitReportView(),
        SensorDashboardScreen.routeName: (_) => const SensorDashboardScreen(),
        LightSensorScreen.routeName: (_) => const LightSensorScreen(),
      },
    );
  }
}
