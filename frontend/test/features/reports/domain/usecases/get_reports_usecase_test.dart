import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/features/reports/domain/entities/report_entity.dart';
import 'package:civic_connect/features/reports/domain/usecases/get_reports_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../helpers/mocks.mocks.dart';

void main() {
  late MockReportRepository mockRepository;
  late GetReportsUsecase usecase;

  final tReports = [
    ReportEntity(
      reportId: '1',
      title: 'Pothole on Main St',
      description: 'Large pothole near intersection',
      category: 'Maintenance',
      status: 'pending',
      location: 'Main St',
      submittedBy: 'user@test.com',
      createdAt: DateTime(2026, 1, 15),
    ),
  ];

  setUp(() {
    mockRepository = MockReportRepository();
    usecase = GetReportsUsecase(mockRepository);
  });

  test('should return list of reports when fetch is successful', () async {
    when(mockRepository.getReports()).thenAnswer((_) async => Right(tReports));

    final result = await usecase.call();

    expect(result, Right(tReports));
    verify(mockRepository.getReports()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ApiFailure when fetch fails', () async {
    const failure = ApiFailure(message: 'Unable to load reports');
    when(mockRepository.getReports()).thenAnswer((_) async => const Left(failure));

    final result = await usecase.call();

    expect(result, const Left(failure));
    verify(mockRepository.getReports()).called(1);
  });
}
