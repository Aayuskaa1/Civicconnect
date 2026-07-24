import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';
import 'package:civic_connect/features/auth/domain/usecases/login_usecase.dart';
import 'package:civic_connect/features/auth/domain/usecases/register_usecase.dart';
import 'package:civic_connect/features/auth/presentation/pages/login_view.dart';
import 'package:civic_connect/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../helpers/mocks.mocks.dart';

void main() {
  late MockAuthRepository mockRepository;

  Widget buildTestWidget({List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: [
        loginUsecaseProvider.overrideWith((ref) => LoginUsecase(mockRepository)),
        registerUsecaseProvider.overrideWith((ref) => RegisterUsecase(mockRepository)),
        ...overrides,
      ],
      child: MaterialApp(
        home: const LoginView(),
        routes: {
          '/dashboard': (_) => const Scaffold(body: Text('Dashboard')),
          '/signup': (_) => const Scaffold(body: Text('Signup Page')),
        },
      ),
    );
  }

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  testWidgets('renders login form UI elements', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('CivicConnect'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });

  testWidgets('shows email validation error when email is empty', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your email'), findsOneWidget);
    verifyNever(mockRepository.login(any, any));
  });

  testWidgets('shows password validation error when password is too short', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'user@test.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    verifyNever(mockRepository.login(any, any));
  });

  testWidgets('calls login usecase when form is valid', (WidgetTester tester) async {
    const user = AuthEntity(
      authId: 'auth-1',
      email: 'user@test.com',
      fullName: 'Test User',
    );
    when(mockRepository.login('user@test.com', 'password123'))
        .thenAnswer((_) async => const Right(user));

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'user@test.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    // Avoid pumpAndSettle — SnackBar / progress animations can run indefinitely.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    verify(mockRepository.login('user@test.com', 'password123')).called(1);
    expect(find.text('Dashboard'), findsOneWidget);
  });

  testWidgets('shows error snackbar when login fails', (WidgetTester tester) async {
    when(mockRepository.login('user@test.com', 'password123')).thenAnswer(
      (_) async => const Left(ApiFailure(message: 'Invalid credentials')),
    );

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'user@test.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Invalid credentials'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
