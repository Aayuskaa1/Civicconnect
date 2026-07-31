import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/features/reports/domain/entities/report_entity.dart';
import 'package:civic_connect/features/reports/domain/usecases/update_report_status_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocktail_mocks.dart';

void main() {
  late MockReportRepository mockRepository;
  late UpdateReportStatusUsecase usecase;

  final tUpdated = ReportEntity(
    reportId: 'r1',
    title: 'Broken light',
    description: 'Hallway dark',
    category: 'Lighting',
    status: 'resolved',
    location: 'Block A',
    submittedBy: 'user@test.com',
    createdAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockRepository = MockReportRepository();
    usecase = UpdateReportStatusUsecase(mockRepository);
  });

  test('updateReportStatus returns updated report on success', () async {
    when(() => mockRepository.updateReportStatus('r1', 'resolved'))
        .thenAnswer((_) async => Right(tUpdated));

    final result = await usecase(
      const UpdateReportStatusParams(reportId: 'r1', status: 'resolved'),
    );

    expect(result.isRight(), isTrue);
    result.fold((_) => fail('expected Right'), (report) {
      expect(report.status, 'resolved');
    });
    verify(() => mockRepository.updateReportStatus('r1', 'resolved')).called(1);
  });

  test('updateReportStatus returns failure when report missing', () async {
    const failure = ApiFailure(message: 'Complaint not found', statusCode: 404);
    when(() => mockRepository.updateReportStatus(any(), any()))
        .thenAnswer((_) async => const Left(failure));

    final result = await usecase(
      const UpdateReportStatusParams(reportId: 'missing', status: 'pending'),
    );

    expect(result, const Left(failure));
  });

  test('updateReportStatus forwards in_progress status', () async {
    when(() => mockRepository.updateReportStatus(any(), any()))
        .thenAnswer((_) async => Right(tUpdated.copyWith(status: 'in_progress')));

    await usecase(
      const UpdateReportStatusParams(reportId: 'r1', status: 'in_progress'),
    );

    verify(() => mockRepository.updateReportStatus('r1', 'in_progress'))
        .called(1);
  });
}

extension on ReportEntity {
  ReportEntity copyWith({String? status}) {
    return ReportEntity(
      reportId: reportId,
      title: title,
      description: description,
      category: category,
      status: status ?? this.status,
      imageUrl: imageUrl,
      location: location,
      submittedBy: submittedBy,
      createdAt: createdAt,
    );
  }
}
