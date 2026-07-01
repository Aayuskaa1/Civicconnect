import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/features/reports/domain/entities/report_entity.dart';
import 'package:civic_connect/features/reports/domain/usecases/submit_report_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../helpers/mocks.mocks.dart';

void main() {
  late MockReportRepository mockRepository;
  late SubmitReportUsecase usecase;

  final tReport = ReportEntity(
    reportId: '',
    title: 'Water leak',
    description: 'Pipe burst on corner',
    category: 'Water',
    status: 'pending',
    location: 'Elm St',
    submittedBy: 'user@test.com',
    createdAt: DateTime(2026, 3, 1),
  );
  final tParams = SubmitReportParams(report: tReport, imagePath: '/tmp/image.jpg');
  final tSubmittedReport = ReportEntity(
    reportId: '99',
    title: tReport.title,
    description: tReport.description,
    category: tReport.category,
    status: tReport.status,
    location: tReport.location,
    submittedBy: tReport.submittedBy,
    createdAt: tReport.createdAt,
  );

  setUp(() {
    mockRepository = MockReportRepository();
    usecase = SubmitReportUsecase(mockRepository);
  });

  test('should return submitted report when submission is successful', () async {
    when(mockRepository.submitReport(tReport, tParams.imagePath))
        .thenAnswer((_) async => Right(tSubmittedReport));

    final result = await usecase.call(tParams);

    expect(result, Right(tSubmittedReport));
    verify(mockRepository.submitReport(tReport, tParams.imagePath)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ApiFailure when submission fails', () async {
    const failure = ApiFailure(message: 'Failed to submit report');
    when(mockRepository.submitReport(tReport, tParams.imagePath))
        .thenAnswer((_) async => const Left(failure));

    final result = await usecase.call(tParams);

    expect(result, const Left(failure));
    verify(mockRepository.submitReport(tReport, tParams.imagePath)).called(1);
  });
}
