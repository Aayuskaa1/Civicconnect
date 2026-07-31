import 'package:civic_connect/features/reports/domain/entities/report_entity.dart';
import 'package:civic_connect/features/reports/presentation/state/report_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ReportState.initial is empty and not loading', () {
    final state = ReportState.initial();
    expect(state.isLoading, isFalse);
    expect(state.reports, isEmpty);
    expect(state.isSuccess, isFalse);
  });

  test('copyWith replaces report lists', () {
    final report = ReportEntity(
      reportId: 'r1',
      title: 'Leak',
      description: 'Water leak',
      category: 'Water',
      status: 'pending',
      location: 'Block A',
      submittedBy: 'u@test.com',
      createdAt: DateTime(2026, 1, 1),
    );
    final state = ReportState.initial().copyWith(reports: [report]);
    expect(state.reports, hasLength(1));
    expect(state.reports.first.title, 'Leak');
  });

  test('copyWith clears error message', () {
    final state = ReportState.initial().copyWith(errorMessage: 'Network error');
    final cleared = state.copyWith(errorMessage: null);
    expect(cleared.errorMessage, isNull);
  });
}
