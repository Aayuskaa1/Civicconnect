import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:civic_connect/features/complaint/data/datasources/local/complaint_local_datasource.dart';
import 'package:civic_connect/features/complaint/data/repositories/complaint_repository_impl.dart';
import 'package:civic_connect/features/complaint/domain/entities/complaint_entity.dart';
import 'package:civic_connect/features/complaint/domain/repositories/i_complaint_repository.dart';
import 'package:civic_connect/features/complaint/domain/usecases/create_complaint_usecase.dart';
import 'package:civic_connect/features/complaint/domain/usecases/get_complaints_usecase.dart';
import 'package:civic_connect/features/complaint/presentation/state/complaint_state.dart';

final complaintLocalDatasourceProvider = Provider<ComplaintLocalDatasource>((ref) {
  return ComplaintLocalDatasource(hiveService: ref.read(hiveServiceProvider));
});

final complaintRepositoryProvider = Provider<IComplaintRepository>((ref) {
  return ComplaintRepositoryImpl(dataSource: ref.read(complaintLocalDatasourceProvider));
});

final getComplaintsUsecaseProvider = Provider<GetComplaintsUseCase>((ref) {
  return GetComplaintsUseCase(ref.read(complaintRepositoryProvider));
});

final createComplaintUsecaseProvider = Provider<CreateComplaintUseCase>((ref) {
  return CreateComplaintUseCase(ref.read(complaintRepositoryProvider));
});

final complaintViewModelProvider =
    StateNotifierProvider<ComplaintNotifier, ComplaintState>((ref) {
  return ComplaintNotifier(
    getComplaintsUsecase: ref.read(getComplaintsUsecaseProvider),
    createComplaintUsecase: ref.read(createComplaintUsecaseProvider),
  );
});

class ComplaintNotifier extends StateNotifier<ComplaintState> {
  final GetComplaintsUseCase _getComplaintsUsecase;
  final CreateComplaintUseCase _createComplaintUsecase;

  ComplaintNotifier({
    required GetComplaintsUseCase getComplaintsUsecase,
    required CreateComplaintUseCase createComplaintUsecase,
  })  : _getComplaintsUsecase = getComplaintsUsecase,
        _createComplaintUsecase = createComplaintUsecase,
        super(const ComplaintState());

  Future<void> loadComplaints(String userEmail) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _getComplaintsUsecase(GetComplaintsParams(userEmail: userEmail));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (complaints) => state = state.copyWith(isLoading: false, complaints: complaints),
    );
  }

  Future<void> createComplaint(ComplaintEntity entity) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _createComplaintUsecase(entity);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (complaint) => state = state.copyWith(
        isLoading: false,
        complaints: [complaint, ...state.complaints],
      ),
    );
  }
}
