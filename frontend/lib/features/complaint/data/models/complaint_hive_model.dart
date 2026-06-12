import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:civic_connect/features/complaint/domain/entities/complaint_entity.dart';

part 'complaint_hive_model.g.dart';

@HiveType(typeId: 2)
class ComplaintHiveModel extends HiveObject {
  @HiveField(0) final String complaintId;
  @HiveField(1) final String title;
  @HiveField(2) final String description;
  @HiveField(3) final String category;
  @HiveField(4) final String status;
  @HiveField(5) final String userEmail;

  ComplaintHiveModel({
    String? complaintId,
    required this.title,
    required this.description,
    required this.category,
    String? status,
    required this.userEmail,
  })  : complaintId = complaintId ?? const Uuid().v4(),
        status = status ?? 'New';

  factory ComplaintHiveModel.fromEntity(ComplaintEntity entity) => ComplaintHiveModel(
        complaintId: entity.complaintId,
        title: entity.title,
        description: entity.description,
        category: entity.category,
        status: entity.status,
        userEmail: entity.userEmail,
      );

  ComplaintEntity toEntity() => ComplaintEntity(
        complaintId: complaintId,
        title: title,
        description: description,
        category: category,
        status: status,
        userEmail: userEmail,
      );
}
