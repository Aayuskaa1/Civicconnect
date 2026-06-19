import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:civic_connect/features/reports/domain/entities/report_entity.dart';

part 'report_hive_model.g.dart';

@HiveType(typeId: 1)
class ReportHiveModel extends HiveObject {
  @HiveField(0)
  final String reportId;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final String status;

  @HiveField(5)
  final String? imageUrl;

  @HiveField(6)
  final String location;

  @HiveField(7)
  final String submittedBy;

  @HiveField(8)
  final DateTime createdAt;

  ReportHiveModel({
    String? reportId,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    this.imageUrl,
    required this.location,
    required this.submittedBy,
    required this.createdAt,
  }) : reportId = reportId ?? const Uuid().v4();

  factory ReportHiveModel.fromEntity(ReportEntity entity) {
    return ReportHiveModel(
      reportId: entity.reportId.isEmpty ? const Uuid().v4() : entity.reportId,
      title: entity.title,
      description: entity.description,
      category: entity.category,
      status: entity.status,
      imageUrl: entity.imageUrl,
      location: entity.location,
      submittedBy: entity.submittedBy,
      createdAt: entity.createdAt,
    );
  }

  ReportEntity toEntity() {
    return ReportEntity(
      reportId: reportId,
      title: title,
      description: description,
      category: category,
      status: status,
      imageUrl: imageUrl,
      location: location,
      submittedBy: submittedBy,
      createdAt: createdAt,
    );
  }
}
