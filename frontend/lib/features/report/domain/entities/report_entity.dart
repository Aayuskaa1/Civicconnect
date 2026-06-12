import 'package:equatable/equatable.dart';

class ReportEntity extends Equatable {
  final String? reportId;
  final String reportName;
  final String? status;

  const ReportEntity({
    this.reportId,
    required this.reportName,
    this.status,
  });

  @override
  List<Object?> get props => [reportId, reportName, status];
}