import 'package:equatable/equatable.dart';

class ComplaintEntity extends Equatable {
  final String complaintId;
  final String title;
  final String description;
  final String category;
  final String status;
  final String userEmail;

  const ComplaintEntity({
    required this.complaintId,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.userEmail,
  });

  @override
  List<Object?> get props => [complaintId, title, description, category, status, userEmail];
}
