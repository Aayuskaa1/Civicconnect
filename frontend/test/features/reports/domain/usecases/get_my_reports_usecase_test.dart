import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/features/reports/domain/entities/report_entity.dart';
import 'package:civic_connect/features/reports/domain/usecases/get_my_reports_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../helpers/mocks.mocks.dart';

void main() {
  late MockReportRepository mockRepository;
  late GetMyReportsUsecase usecase;

  const tUserEmail = 'user@test.com';
  final tReports = [
    ReportEntity(
      reportId: '2',
      title: 'Broken streetlight',
      description: 'Light out for 3 days',
      category: 'Electricity',
      status: 'in_progress',
      location: 'Oak Ave',
      submittedBy: tUserEmail,
      createdAt: DateTime(2026, 2, 1),
    ),
  ];

  setUp(() {
    mockRepository = MockReportRepository();
    usecase = GetMyReportsUsecase(mockRepository);
  });

  test('should return user reports when fetch is successful', () async {
    when(mockRepository.getMyReports(tUserEmail))
        .thenAnswer((_) async => Right(tReports));

    final result = await usecase.call(tUserEmail);

    expect(result, Right(tReports));
    verify(mockRepository.getMyReports(tUserEmail)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return LocalDatabaseFailure when fetch fails', () async {
    const failure = LocalDatabaseFailure('No cached reports found');
    when(mockRepository.getMyReports(tUserEmail))
        .thenAnswer((_) async => const Left(failure));

    final result = await usecase.call(tUserEmail);

    expect(result, const Left(failure));
    verify(mockRepository.getMyReports(tUserEmail)).called(1);
  });
}
