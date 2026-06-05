import 'package:hive/hive.dart';
import 'package:civic_connect/features/report/domain/entities/report_entity.dart';
import 'package:uuid/uuid.dart';

part 'report_hive_model.g.dart';

@HiveType(typeId: 1)
class ReportHiveModel extends HiveObject {
  @HiveField(0) final String reportId;
  @HiveField(1) final String reportName;
  @HiveField(2) final String status;

  ReportHiveModel({
    String? reportId,
    required this.reportName,
    String? status,
  })  : reportId = reportId ?? const Uuid().v4(),
        status = status ?? 'pending';

  ReportEntity toEntity() => ReportEntity(
        reportId: reportId,
        reportName: reportName,
        status: status,
      );

  factory ReportHiveModel.fromEntity(ReportEntity entity) => ReportHiveModel(
        reportId: entity.reportId,
        reportName: entity.reportName,
        status: entity.status ?? 'pending',
      );
}
