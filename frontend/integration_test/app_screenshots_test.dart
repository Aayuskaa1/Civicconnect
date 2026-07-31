import 'package:civic_connect/app/theme/my_theme.dart';
import 'package:civic_connect/core/providers/shared_prefs_provider.dart';
import 'package:civic_connect/features/auth/presentation/pages/login_view.dart';
import 'package:civic_connect/features/auth/presentation/pages/signup_view.dart';
import 'package:civic_connect/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:civic_connect/features/dashboard/presentation/pages/edit_profile_screen.dart';
import 'package:civic_connect/features/onboarding/presentation/pages/on_boarding_view.dart';
import 'package:civic_connect/features/reports/presentation/pages/submit_report_view.dart';
import 'package:civic_connect/features/sensors/presentation/pages/light_sensor_screen.dart';
import 'package:civic_connect/features/sensors/presentation/pages/sensor_dashboard_screen.dart';
import 'package:civic_connect/features/splash/presentation/pages/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> capture(WidgetTester tester, String name) async {
    await tester.pumpAndSettle(const Duration(milliseconds: 800));
    await IntegrationTestWidgetsFlutterBinding.instance.takeScreenshot(name);
  }

  Future<void> pump(WidgetTester tester, Widget child) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: MyTheme.lightTheme,
          darkTheme: MyTheme.darkTheme,
          home: child,
          routes: {
            '/login': (_) => const LoginView(),
            '/signup': (_) => const SignupView(),
            '/dashboard': (_) => const DashboardScreen(),
            EditProfileScreen.routeName: (_) => const EditProfileScreen(),
            '/submit-report': (_) => const SubmitReportView(),
            SensorDashboardScreen.routeName: (_) => const SensorDashboardScreen(),
            LightSensorScreen.routeName: (_) => const LightSensorScreen(),
          },
        ),
      ),
    );
  }

  testWidgets('capture all app screens for documentation', (tester) async {
    await pump(tester, const SplashView());
    await capture(tester, '01_splash');

    await pump(tester, const OnBoardingView());
    await capture(tester, '02_onboarding_page1');
    final next = find.text('Next');
    if (next.evaluate().isNotEmpty) {
      await tester.tap(next);
      await capture(tester, '03_onboarding_page2');
      if (next.evaluate().isNotEmpty) {
        await tester.tap(next);
        await capture(tester, '04_onboarding_page3');
      }
    }

    await pump(tester, const LoginView());
    await capture(tester, '05_login');

    await pump(tester, const SignupView());
    await capture(tester, '06_signup');

    await pump(tester, const DashboardScreen());
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await capture(tester, '07_home');

    for (final tab in ['Reports', 'Submit', 'Ask AI', 'Profile']) {
      if (find.text(tab).evaluate().isNotEmpty) {
        await tester.tap(find.text(tab));
        await capture(tester, '08_${tab.toLowerCase().replaceAll(' ', '_')}');
      }
    }

    if (find.text('Sensor Dashboard').evaluate().isNotEmpty) {
      await tester.tap(find.text('Sensor Dashboard'));
      await capture(tester, '12_sensor_dashboard');

      if (find.text('Light Sensor').evaluate().isNotEmpty) {
        await tester.tap(find.text('Light Sensor'));
        await capture(tester, '13_light_sensor');
        await tester.pageBack();
      }

      if (find.text('Test low light prompt').evaluate().isNotEmpty) {
        await tester.tap(find.text('Test low light prompt'));
        await capture(tester, '14_low_light_dialog');
        if (find.text('Not now').evaluate().isNotEmpty) {
          await tester.tap(find.text('Not now'));
          await tester.pumpAndSettle();
        }
      }
      await tester.pageBack();
    }

    final editProfile = find.text('Edit Profile');
    if (editProfile.evaluate().isNotEmpty) {
      await tester.tap(editProfile);
      await capture(tester, '15_edit_profile');
    }
  });
}
