import 'package:civic_connect/app.dart';
import 'package:civic_connect/core/providers/shared_prefs_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App renders splash page', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: App(),
      ),
    );

    expect(find.text('CivicConnect'), findsOneWidget);
    expect(find.text('Report and track building issues.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
  });
}
