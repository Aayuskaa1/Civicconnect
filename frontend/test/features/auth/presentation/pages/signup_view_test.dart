import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/features/auth/domain/usecases/login_usecase.dart';
import 'package:civic_connect/features/auth/domain/usecases/register_usecase.dart';
import 'package:civic_connect/features/auth/presentation/pages/signup_view.dart';
import 'package:civic_connect/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../helpers/mocks.mocks.dart';

void main() {
  late MockAuthRepository mockRepository;

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        loginUsecaseProvider.overrideWith((ref) => LoginUsecase(mockRepository)),
        registerUsecaseProvider.overrideWith((ref) => RegisterUsecase(mockRepository)),
      ],
      child: MaterialApp(
        home: const SignupView(),
      ),
    );
  }

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  testWidgets('renders signup form UI elements', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsOneWidget);
  });

  testWidgets('shows full name validation error when empty', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your full name'), findsOneWidget);
    verifyNever(mockRepository.register(any));
  });

  testWidgets('shows password mismatch validation error', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Jane Doe');
    await tester.enterText(find.byType(TextFormField).at(1), 'jane@test.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await tester.enterText(find.byType(TextFormField).at(3), 'different123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Passwords do not match'), findsOneWidget);
    verifyNever(mockRepository.register(any));
  });

  testWidgets('calls register usecase when form is valid', (WidgetTester tester) async {
    when(mockRepository.register(any)).thenAnswer((_) async => const Right(true));

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Jane Doe');
    await tester.enterText(find.byType(TextFormField).at(1), 'jane@test.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await tester.enterText(find.byType(TextFormField).at(3), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
    await tester.pumpAndSettle();

    verify(mockRepository.register(any)).called(1);
    expect(find.byType(SignupView), findsNothing);
  });

  testWidgets('shows error snackbar when registration fails', (WidgetTester tester) async {
    when(mockRepository.register(any)).thenAnswer(
      (_) async => const Left(ApiFailure(message: 'Email already exists')),
    );

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Jane Doe');
    await tester.enterText(find.byType(TextFormField).at(1), 'jane@test.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await tester.enterText(find.byType(TextFormField).at(3), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Email already exists'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
