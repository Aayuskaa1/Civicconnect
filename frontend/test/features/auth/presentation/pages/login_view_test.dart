import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';
import 'package:civic_connect/features/auth/domain/usecases/login_usecase.dart';
import 'package:civic_connect/features/auth/domain/usecases/register_usecase.dart';
import 'package:civic_connect/features/auth/presentation/pages/login_view.dart';
import 'package:civic_connect/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocktail_mocks.dart';

void main() {
  late MockAuthRepository mockRepository;

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        loginUsecaseProvider.overrideWith((ref) => LoginUsecase(mockRepository)),
        registerUsecaseProvider
            .overrideWith((ref) => RegisterUsecase(mockRepository)),
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

  testWidgets('renders login form UI elements', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('CivicConnect'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });

  testWidgets('shows email validation error when email is empty', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your email'), findsOneWidget);
    verifyNever(() => mockRepository.login(any(), any()));
  });

  testWidgets('shows password validation error when password is too short',
      (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'user@test.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    verifyNever(() => mockRepository.login(any(), any()));
  });

  testWidgets('calls login usecase when form is valid', (tester) async {
    const user = AuthEntity(
      authId: 'auth-1',
      email: 'user@test.com',
      fullName: 'Test User',
    );
    when(() => mockRepository.login('user@test.com', 'password123'))
        .thenAnswer((_) async => const Right(user));

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'user@test.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    verify(() => mockRepository.login('user@test.com', 'password123')).called(1);
  });

  testWidgets('navigates to signup page when Sign Up is tapped', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Signup Page'), findsOneWidget);
  });
}
