import 'package:civic_connect/features/report/domain/entities/report_entity.dart';

class ReportState {
  final bool isLoading;
  final List<ReportEntity> reports;
  final String? error;

  const ReportState({
    this.isLoading = false,
    this.reports = const [],
    this.error,
  });

  ReportState copyWith({
    bool? isLoading,
    List<ReportEntity>? reports,
    String? error,
  }) =>
      ReportState(
        isLoading: isLoading ?? this.isLoading,
        reports: reports ?? this.reports,
        error: error,
      );
}
