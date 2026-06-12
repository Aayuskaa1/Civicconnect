import 'package:civic_connect/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders splash page', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.text('CIVIC CONNECT'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });
}
