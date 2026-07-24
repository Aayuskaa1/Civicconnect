import 'package:civic_connect/core/api/api_client.dart';
import 'package:civic_connect/core/providers/shared_prefs_provider.dart';
import 'package:civic_connect/core/services/hive/hive_services.dart';
import 'package:civic_connect/features/auth/presentation/pages/login_view.dart';
import 'package:civic_connect/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:civic_connect/features/dashboard/presentation/pages/edit_profile_screen.dart';
import 'package:civic_connect/features/auth/presentation/pages/signup_view.dart';
import 'package:civic_connect/features/onboarding/presentation/pages/on_boarding_view.dart';
import 'package:civic_connect/features/reports/presentation/pages/submit_report_view.dart';
import 'package:civic_connect/app/theme/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('live login reaches dashboard without hang', (tester) async {
    final hive = HiveServices();
    await hive.init();
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: MyTheme.themeData,
          navigatorKey: globalNavigatorKey,
          home: const LoginView(),
          routes: {
            '/onboarding': (_) => const OnBoardingView(),
            '/login': (_) => const LoginView(),
            '/signup': (_) => const SignupView(),
            '/dashboard': (_) => const DashboardScreen(),
            EditProfileScreen.routeName: (_) => const EditProfileScreen(),
            '/submit-report': (_) => const SubmitReportView(),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('For your building community'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));

    // Login should finish well under the old hang window.
    final deadline = DateTime.now().add(const Duration(seconds: 12));
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 200));
      if (find.text('Home').evaluate().isNotEmpty ||
          find.text('Dashboard').evaluate().isNotEmpty ||
          find.byType(DashboardScreen).evaluate().isNotEmpty) {
        break;
      }
    }

    expect(
      find.byType(DashboardScreen),
      findsOneWidget,
      reason: 'Expected dashboard after live login',
    );
  });
}
