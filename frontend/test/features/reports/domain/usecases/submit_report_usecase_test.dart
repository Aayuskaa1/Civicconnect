import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/features/reports/domain/entities/report_entity.dart';
import 'package:civic_connect/features/reports/domain/usecases/submit_report_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocktail_mocks.dart';

void main() {
  late MockReportRepository mockRepository;
  late SubmitReportUsecase usecase;

  final tReport = ReportEntity(
    reportId: '',
    title: 'Noise complaint',
    description: 'Loud music',
    category: 'Noise',
    status: 'pending',
    location: 'Block C',
    submittedBy: 'user@test.com',
    createdAt: DateTime(2026, 3, 1),
  );

  final tSaved = ReportEntity(
    reportId: 'saved-1',
    title: tReport.title,
    description: tReport.description,
    category: tReport.category,
    status: tReport.status,
    location: tReport.location,
    submittedBy: tReport.submittedBy,
    createdAt: tReport.createdAt,
  );

  setUpAll(() {
    registerFallbackValue(tReport);
  });

  setUp(() {
    mockRepository = MockReportRepository();
    usecase = SubmitReportUsecase(mockRepository);
  });

  test('submitReport returns saved report on success', () async {
    when(() => mockRepository.submitReport(any(), any()))
        .thenAnswer((_) async => Right(tSaved));

    final result = await usecase(
      SubmitReportParams(report: tReport, imagePath: null),
    );

    expect(result, Right(tSaved));
    verify(() => mockRepository.submitReport(tReport, null)).called(1);
  });

  test('submitReport passes imagePath to repository', () async {
    when(() => mockRepository.submitReport(any(), any()))
        .thenAnswer((_) async => Right(tSaved));

    await usecase(
      SubmitReportParams(report: tReport, imagePath: '/tmp/photo.jpg'),
    );

    verify(() => mockRepository.submitReport(tReport, '/tmp/photo.jpg'))
        .called(1);
  });

  test('submitReport returns ApiFailure on failure', () async {
    const failure = ApiFailure(message: 'Upload failed');
    when(() => mockRepository.submitReport(any(), any()))
        .thenAnswer((_) async => const Left(failure));

    final result = await usecase(
      SubmitReportParams(report: tReport),
    );

    expect(result, const Left(failure));
  });
}
