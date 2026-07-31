import 'package:civic_connect/features/reports/domain/entities/report_entity.dart';
import 'package:civic_connect/features/reports/domain/usecases/get_my_reports_usecase.dart';
import 'package:civic_connect/features/reports/domain/usecases/get_reports_usecase.dart';
import 'package:civic_connect/features/reports/domain/usecases/submit_report_usecase.dart';
import 'package:civic_connect/features/reports/domain/usecases/update_report_status_usecase.dart';
import 'package:civic_connect/features/reports/presentation/pages/report_list_view.dart';
import 'package:civic_connect/features/reports/presentation/view_model/report_view_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocktail_mocks.dart';

void main() {
  late MockReportRepository mockRepository;

  final tReport = ReportEntity(
    reportId: 'r1',
    title: 'Broken hallway light',
    description: 'Dark corridor',
    category: 'Lighting',
    status: 'pending',
    location: 'Block A',
    submittedBy: 'user@test.com',
    createdAt: DateTime(2026, 1, 1),
  );

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        getReportsUsecaseProvider
            .overrideWith((ref) => GetReportsUsecase(mockRepository)),
        getMyReportsUsecaseProvider
            .overrideWith((ref) => GetMyReportsUsecase(mockRepository)),
        submitReportUsecaseProvider
            .overrideWith((ref) => SubmitReportUsecase(mockRepository)),
        updateReportStatusUsecaseProvider
            .overrideWith((ref) => UpdateReportStatusUsecase(mockRepository)),
      ],
      child: const MaterialApp(home: ReportListView()),
    );
  }

  setUpAll(() {
    registerFallbackValue(tReport);
  });

  setUp(() {
    mockRepository = MockReportRepository();
    when(() => mockRepository.getReports())
        .thenAnswer((_) async => Right([tReport]));
  });

  testWidgets('renders Reports app bar title', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Reports'), findsOneWidget);
  });

  testWidgets('shows report title from repository', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Broken hallway light'), findsOneWidget);
    verify(() => mockRepository.getReports()).called(greaterThanOrEqualTo(1));
  });

  testWidgets('shows category filter chips', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('All'), findsWidgets);
    expect(find.text('Water'), findsOneWidget);
    expect(find.text('Lighting'), findsWidgets);
  });

  testWidgets('filters by status chip Pending', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilterChip, 'Pending'));
    await tester.pumpAndSettle();

    expect(find.text('Broken hallway light'), findsOneWidget);
  });

  testWidgets('shows empty state when repository returns no reports',
      (tester) async {
    when(() => mockRepository.getReports())
        .thenAnswer((_) async => const Right([]));

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('No reports match your filters.'), findsOneWidget);
  });
}
