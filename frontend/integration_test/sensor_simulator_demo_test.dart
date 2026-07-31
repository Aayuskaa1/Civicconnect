import 'package:civic_connect/core/providers/shared_prefs_provider.dart';
import 'package:civic_connect/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:civic_connect/features/reports/presentation/pages/submit_report_view.dart';
import 'package:civic_connect/app/theme/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Demonstrates sensor simulate buttons on iOS Simulator (bright room / no real sensors).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('simulator sensor demo: low light, shake, bump', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: MyTheme.themeData,
          home: const DashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Profile → Sensor Dashboard → test buttons
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sensor Dashboard'));
    await tester.pumpAndSettle();

    expect(find.text('Sensor Dashboard'), findsOneWidget);
    expect(find.text('Test low light prompt'), findsOneWidget);

    // 1) Low light simulation
    await tester.tap(find.text('Test low light prompt'));
    await tester.pumpAndSettle();
    expect(find.text('Low light detected'), findsOneWidget);
    await tester.tap(find.text('Report issue'));
    await tester.pumpAndSettle();
    expect(find.byType(SubmitReportView), findsOneWidget);
    expect(find.text('Lighting'), findsWidgets);

    // Back to Home tab
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    // 2) Shake simulation
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sensor Dashboard'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Test shake → Report'));
    await tester.pumpAndSettle();
    // Snackbar may dismiss quickly; Submit tab opening is the main behavior.
    expect(find.byType(SubmitReportView), findsOneWidget);

    // 3) Hard bump simulation
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Light sensor live lux · shake · bump tests'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Test hard bump'));
    await tester.pumpAndSettle();
    expect(find.text('Hard bump detected'), findsOneWidget);
    await tester.tap(find.text('Report issue'));
    await tester.pumpAndSettle();
    expect(find.byType(SubmitReportView), findsOneWidget);
    expect(find.text('Safety'), findsWidgets);
  });
}
