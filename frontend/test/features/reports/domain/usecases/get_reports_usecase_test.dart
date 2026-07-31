import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/features/reports/domain/entities/report_entity.dart';
import 'package:civic_connect/features/reports/domain/usecases/get_reports_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocktail_mocks.dart';

void main() {
  late MockReportRepository mockRepository;
  late GetReportsUsecase usecase;

  final tReport = ReportEntity(
    reportId: 'r1',
    title: 'Broken light',
    description: 'Hallway dark',
    category: 'Lighting',
    status: 'pending',
    location: 'Block A',
    submittedBy: 'user@test.com',
    createdAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockRepository = MockReportRepository();
    usecase = GetReportsUsecase(mockRepository);
  });

  test('getReports returns list on success', () async {
    when(() => mockRepository.getReports())
        .thenAnswer((_) async => Right([tReport]));

    final result = await usecase();

    expect(result.isRight(), isTrue);
    result.fold((_) => fail('expected Right'), (list) {
      expect(list, hasLength(1));
      expect(list.first.title, 'Broken light');
    });
    verify(() => mockRepository.getReports()).called(1);
  });

  test('getReports returns empty list when no reports', () async {
    when(() => mockRepository.getReports())
        .thenAnswer((_) async => const Right([]));

    final result = await usecase();

    expect(result, const Right(<ReportEntity>[]));
  });

  test('getReports returns ApiFailure on network error', () async {
    const failure = ApiFailure(message: 'Network error', statusCode: 500);
    when(() => mockRepository.getReports())
        .thenAnswer((_) async => const Left(failure));

    final result = await usecase();

    expect(result, const Left(failure));
  });
}
