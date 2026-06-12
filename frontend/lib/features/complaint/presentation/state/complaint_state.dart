import 'package:civic_connect/features/complaint/domain/entities/complaint_entity.dart';

class ComplaintState {
  final bool isLoading;
  final List<ComplaintEntity> complaints;
  final String? error;

  const ComplaintState({
    this.isLoading = false,
    this.complaints = const [],
    this.error,
  });

  ComplaintState copyWith({
    bool? isLoading,
    List<ComplaintEntity>? complaints,
    String? error,
  }) =>
      ComplaintState(
        isLoading: isLoading ?? this.isLoading,
        complaints: complaints ?? this.complaints,
        error: error,
      );
}
