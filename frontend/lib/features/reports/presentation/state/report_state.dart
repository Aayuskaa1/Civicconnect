import 'package:civic_connect/features/reports/domain/entities/report_entity.dart';

const Object _reportStateUnset = Object();

class ReportState {
  final bool isLoading;
  final List<ReportEntity> reports;
  final List<ReportEntity> myReports;
  final String? errorMessage;
  final bool isSuccess;

  const ReportState({
    required this.isLoading,
    required this.reports,
    required this.myReports,
    this.errorMessage,
    required this.isSuccess,
  });

  factory ReportState.initial() => const ReportState(
        isLoading: false,
        reports: [],
        myReports: [],
        errorMessage: null,
        isSuccess: false,
      );

  ReportState copyWith({
    bool? isLoading,
    List<ReportEntity>? reports,
    List<ReportEntity>? myReports,
    Object? errorMessage = _reportStateUnset,
    bool? isSuccess,
  }) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      reports: reports ?? this.reports,
      myReports: myReports ?? this.myReports,
      errorMessage: identical(errorMessage, _reportStateUnset)
          ? this.errorMessage
          : errorMessage as String?,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
