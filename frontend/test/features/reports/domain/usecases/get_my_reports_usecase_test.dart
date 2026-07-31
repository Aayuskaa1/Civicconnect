import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/features/reports/domain/entities/report_entity.dart';
import 'package:civic_connect/features/reports/domain/usecases/get_my_reports_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocktail_mocks.dart';

void main() {
  late MockReportRepository mockRepository;
  late GetMyReportsUsecase usecase;

  const tUserEmail = 'user@test.com';
  final tReport = ReportEntity(
    reportId: 'r2',
    title: 'Water leak',
    description: 'Kitchen sink',
    category: 'Water',
    status: 'in_progress',
    location: 'Flat 12',
    submittedBy: tUserEmail,
    createdAt: DateTime(2026, 2, 1),
  );

  setUp(() {
    mockRepository = MockReportRepository();
    usecase = GetMyReportsUsecase(mockRepository);
  });

  test('getMyReports returns user reports on success', () async {
    when(() => mockRepository.getMyReports(tUserEmail))
        .thenAnswer((_) async => Right([tReport]));

    final result = await usecase(tUserEmail);

    expect(result.isRight(), isTrue);
    verify(() => mockRepository.getMyReports(tUserEmail)).called(1);
  });

  test('getMyReports returns empty list for user with no reports', () async {
    when(() => mockRepository.getMyReports(tUserEmail))
        .thenAnswer((_) async => const Right([]));

    final result = await usecase(tUserEmail);

    expect(result, const Right(<ReportEntity>[]));
  });

  test('getMyReports returns failure when repository fails', () async {
    const failure = ApiFailure(message: 'Unauthorized', statusCode: 401);
    when(() => mockRepository.getMyReports(any()))
        .thenAnswer((_) async => const Left(failure));

    final result = await usecase(tUserEmail);

    expect(result, const Left(failure));
  });
}
