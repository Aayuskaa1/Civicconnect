import 'package:civic_connect/features/reports/domain/entities/report_entity.dart';

class ReportApiModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String status;
  final String? imageUrl;
  final String location;
  final String submittedBy;
  final DateTime createdAt;

  ReportApiModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    this.imageUrl,
    required this.location,
    required this.submittedBy,
    required this.createdAt,
  });

  factory ReportApiModel.fromJson(Map<String, dynamic> json) {
    return ReportApiModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      category: (json['category'] ?? 'Other') as String,
      status: (json['status'] ?? 'pending') as String,
      imageUrl: json['imageUrl'] as String?,
      location: (json['location'] ?? '') as String,
      submittedBy: (json['submittedBy'] ?? '') as String,
      createdAt: json['createdAt'] == null
          ? DateTime.now()
          : DateTime.parse(json['createdAt'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'imageUrl': imageUrl,
      'location': location,
      'submittedBy': submittedBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ReportEntity toEntity() {
    return ReportEntity(
      reportId: id,
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

  static ReportApiModel fromEntity(ReportEntity entity) {
    return ReportApiModel(
      id: entity.reportId,
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
}
