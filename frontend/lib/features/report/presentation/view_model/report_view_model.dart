import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/core/usecases/app_usecase.dart';
import 'package:civic_connect/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:civic_connect/features/report/data/datasources/local/report_local_datasource.dart';
import 'package:civic_connect/features/report/data/repositories/report_repository_impl.dart';
import 'package:civic_connect/features/report/domain/entities/report_entity.dart';
import 'package:civic_connect/features/report/domain/repositories/i_report_repository.dart';
import 'package:civic_connect/features/report/domain/usecases/create_report_usecase.dart';
import 'package:civic_connect/features/report/domain/usecases/get_reports_usecase.dart';
import 'package:civic_connect/features/report/presentation/state/report_state.dart';

final reportLocalDatasourceProvider = Provider<ReportLocalDatasource>((ref) {
  return ReportLocalDatasource(hiveService: ref.read(hiveServiceProvider));
});

final reportRepositoryProvider = Provider<IReportRepository>((ref) {
  return ReportRepositoryImpl(dataSource: ref.read(reportLocalDatasourceProvider));
});

final getReportsUsecaseProvider = Provider<GetReportsUseCase>((ref) {
  return GetReportsUseCase(ref.read(reportRepositoryProvider));
});

final createReportUsecaseProvider = Provider<CreateReportUseCase>((ref) {
  return CreateReportUseCase(ref.read(reportRepositoryProvider));
});

final reportViewModelProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  return ReportNotifier(
    getReportsUsecase: ref.read(getReportsUsecaseProvider),
    createReportUsecase: ref.read(createReportUsecaseProvider),
  );
});

class ReportNotifier extends StateNotifier<ReportState> {
  final GetReportsUseCase _getReportsUsecase;
  final CreateReportUseCase _createReportUsecase;

  ReportNotifier({
    required GetReportsUseCase getReportsUsecase,
    required CreateReportUseCase createReportUsecase,
  })  : _getReportsUsecase = getReportsUsecase,
        _createReportUsecase = createReportUsecase,
        super(const ReportState());

  Future<void> loadReports() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _getReportsUsecase(const NoParams());
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (reports) => state = state.copyWith(isLoading: false, reports: reports),
    );
  }

  Future<void> createReport(ReportEntity entity) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _createReportUsecase(entity);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (report) => state = state.copyWith(
        isLoading: false,
        reports: [report, ...state.reports],
      ),
    );
  }
}
