import 'package:hive/hive.dart';
import 'package:civic_connect/features/report/domain/entities/report_entity.dart';
import 'package:uuid/uuid.dart';

part 'report_hive_model.g.dart';

// HARDCODE the ID here directly. 
// The generator will read this '7' immediately without trying to look up the file.
@HiveType(typeId: 7) 
class ReportHiveModel extends HiveObject {
  @HiveField(0)
  final String? reportId;
  
  @HiveField(1)
  final String reportName;
  
  @HiveField(2)
  final String status;

  ReportHiveModel({
    String? reportId,
    required this.reportName,
    String? status,
  }) : reportId = reportId ?? const Uuid().v4(),
       status = status ?? 'pending';

  ReportEntity toEntity() {
    return ReportEntity(
      reportId: reportId,
      reportName: reportName,
      status: status,
    );
  }

  factory ReportHiveModel.fromEntity(ReportEntity entity) {
    return ReportHiveModel(
      reportId: entity.reportId,
      reportName: entity.reportName,
      status: entity.status ?? 'pending',
    );
  }

  static List<ReportEntity> toEntityList(List<ReportHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}