import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';
import 'package:civic_connect/features/auth/presentation/state/auth_state.dart';
import 'package:civic_connect/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:civic_connect/features/reports/domain/entities/report_entity.dart';
import 'package:civic_connect/features/reports/domain/usecases/get_my_reports_usecase.dart';
import 'package:civic_connect/features/reports/domain/usecases/get_reports_usecase.dart';
import 'package:civic_connect/features/reports/domain/usecases/submit_report_usecase.dart';
import 'package:civic_connect/features/reports/domain/usecases/update_report_status_usecase.dart';
import 'package:civic_connect/features/reports/presentation/view_model/report_view_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocktail_mocks.dart';

void main() {
  late MockReportRepository mockRepository;
  late ProviderContainer container;

  final sampleReport = ReportEntity(
    reportId: 'r1',
    title: 'Broken light',
    description: 'Hallway bulb out',
    category: 'Lighting',
    status: 'pending',
    location: 'Block A',
    submittedBy: 'user@test.com',
    createdAt: DateTime(2026, 3, 1),
  );

  setUpAll(() {
    registerFallbackValue(
      ReportEntity(
        reportId: 'fallback',
        title: 'Fallback',
        description: 'Fallback',
        category: 'Other',
        status: 'pending',
        location: 'Block A',
        submittedBy: 'fallback@test.com',
        createdAt: DateTime(2026, 1, 1),
      ),
    );
  });

  setUp(() {
    mockRepository = MockReportRepository();
    when(() => mockRepository.getReports())
        .thenAnswer((_) async => const Right(<ReportEntity>[]));
    container = ProviderContainer(
      overrides: [
        getReportsUsecaseProvider
            .overrideWith((ref) => GetReportsUsecase(mockRepository)),
        getMyReportsUsecaseProvider
            .overrideWith((ref) => GetMyReportsUsecase(mockRepository)),
        submitReportUsecaseProvider
            .overrideWith((ref) => SubmitReportUsecase(mockRepository)),
        updateReportStatusUsecaseProvider.overrideWith(
          (ref) => UpdateReportStatusUsecase(mockRepository),
        ),
        authViewModelProvider.overrideWith(() => _StubAuthViewModel()),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('loadReports populates reports on success', () async {
    when(() => mockRepository.getReports())
        .thenAnswer((_) async => Right([sampleReport]));

    await container.read(reportViewModelProvider.notifier).loadReports();
    await Future<void>.delayed(Duration.zero);

    final state = container.read(reportViewModelProvider);
    expect(state.isLoading, isFalse);
    expect(state.reports, hasLength(1));
    expect(state.reports.first.title, 'Broken light');
  });

  test('loadReports sets error message on failure', () async {
    when(() => mockRepository.getReports()).thenAnswer(
      (_) async => const Left(ApiFailure(message: 'Network error')),
    );

    await container.read(reportViewModelProvider.notifier).loadReports();
    await Future<void>.delayed(Duration.zero);

    final state = container.read(reportViewModelProvider);
    expect(state.errorMessage, 'Network error');
    expect(state.reports, isEmpty);
  });

  test('submitReport appends report on success', () async {
    when(() => mockRepository.submitReport(any(), any()))
        .thenAnswer((_) async => Right(sampleReport));

    await container.read(reportViewModelProvider.notifier).submitReport(
          'Broken light',
          'Hallway bulb out',
          'Lighting',
          'Block A',
          null,
        );

    final state = container.read(reportViewModelProvider);
    expect(state.isSuccess, isTrue);
    expect(state.reports.first.reportId, 'r1');
  });

  test('updateReportStatus replaces matching report', () async {
    when(() => mockRepository.getReports())
        .thenAnswer((_) async => Right([sampleReport]));
    final resolvedReport = ReportEntity(
      reportId: sampleReport.reportId,
      title: sampleReport.title,
      description: sampleReport.description,
      category: sampleReport.category,
      status: 'resolved',
      imageUrl: sampleReport.imageUrl,
      location: sampleReport.location,
      submittedBy: sampleReport.submittedBy,
      createdAt: sampleReport.createdAt,
    );
    when(() => mockRepository.updateReportStatus('r1', 'resolved'))
        .thenAnswer((_) async => Right(resolvedReport));

    final notifier = container.read(reportViewModelProvider.notifier);
    await notifier.loadReports();
    await Future<void>.delayed(Duration.zero);

    final updated = await notifier.updateReportStatus('r1', 'resolved');
    expect(updated?.status, 'resolved');
    expect(container.read(reportViewModelProvider).reports.first.status, 'resolved');
  });
}

class _StubAuthViewModel extends AuthViewModel {
  @override
  AuthState build() {
    return AuthState.initial().copyWith(
      status: AuthStatus.authenticated,
      user: const AuthEntity(
        authId: 'auth-1',
        email: 'user@test.com',
        fullName: 'Test User',
      ),
    );
  }
}
