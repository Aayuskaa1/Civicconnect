import 'package:civic_connect/features/onboarding/presentation/pages/on_boarding_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildApp() {
    return MaterialApp(
      home: const OnBoardingView(),
      routes: {
        '/login': (_) => const Scaffold(body: Text('Login Page')),
      },
    );
  }

  testWidgets('shows CivicConnect branding on onboarding', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('CivicConnect'), findsWidgets);
    expect(find.text('For your complex'), findsOneWidget);
  });

  testWidgets('shows first onboarding slide content', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome to CivicConnect'), findsOneWidget);
    expect(find.textContaining('Report building issues'), findsOneWidget);
  });

  testWidgets('Skip navigates to login', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Login Page'), findsOneWidget);
  });

  testWidgets('Next moves to second slide', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Report Issues Easily'), findsOneWidget);
  });

  testWidgets('last slide shows Get Started and goes to login', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    // Page through to last slide
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Ask AI Anytime'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Login Page'), findsOneWidget);
  });
}
