import 'package:equatable/equatable.dart';

class ReportEntity extends Equatable {
  final String reportId;
  final String title;
  final String description;
  final String category;      // e.g. Road, Water, Electricity, Safety
  final String status;        // pending, in_progress, resolved
  final String? imageUrl;
  final String location;
  final String submittedBy;
  final DateTime createdAt;

  const ReportEntity({
    required this.reportId,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    this.imageUrl,
    required this.location,
    required this.submittedBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        reportId,
        title,
        description,
        category,
        status,
        imageUrl,
        location,
        submittedBy,
        createdAt,
      ];
}
