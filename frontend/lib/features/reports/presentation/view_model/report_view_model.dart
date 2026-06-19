import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:civic_connect/features/reports/data/datasources/report_datasource.dart';
import 'package:civic_connect/features/reports/data/datasources/local/report_local_datasource.dart';
import 'package:civic_connect/features/reports/data/datasources/remote/report_remote_datasource.dart';
import 'package:civic_connect/features/reports/data/repositories/report_repository.dart';
import 'package:civic_connect/features/reports/domain/entities/report_entity.dart';
import 'package:civic_connect/features/reports/domain/repositories/report_repository.dart';
import 'package:civic_connect/features/reports/domain/usecases/get_my_reports_usecase.dart';
import 'package:civic_connect/features/reports/domain/usecases/get_reports_usecase.dart';
import 'package:civic_connect/features/reports/domain/usecases/submit_report_usecase.dart';
import 'package:civic_connect/features/reports/presentation/state/report_state.dart';

// Reports Providers
final reportRemoteDataSourceProvider = Provider<ReportRemoteDatasource>((ref) {
  return ReportRemoteDatasourceImpl(ref.read(apiClientProvider));
});

final reportLocalDataSourceProvider = Provider<ReportLocalDatasource>((ref) {
  return ReportLocalDatasourceImpl(ref.read(hiveServicesProvider));
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepositoryImpl(
    remoteDataSource: ref.read(reportRemoteDataSourceProvider),
    localDataSource: ref.read(reportLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

final getReportsUsecaseProvider = Provider<GetReportsUsecase>((ref) {
  return GetReportsUsecase(ref.read(reportRepositoryProvider));
});

final getMyReportsUsecaseProvider = Provider<GetMyReportsUsecase>((ref) {
  return GetMyReportsUsecase(ref.read(reportRepositoryProvider));
});

final submitReportUsecaseProvider = Provider<SubmitReportUsecase>((ref) {
  return SubmitReportUsecase(ref.read(reportRepositoryProvider));
});

final reportViewModelProvider = NotifierProvider<ReportViewModel, ReportState>(
  () => ReportViewModel(),
);

class ReportViewModel extends Notifier<ReportState> {
  @override
  ReportState build() {
    Future.microtask(() => loadReports());
    return ReportState.initial();
  }

  Future<void> loadReports() async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    final result = await ref.read(getReportsUsecaseProvider).call();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (reports) => state = state.copyWith(isLoading: false, reports: reports),
    );
  }

  Future<void> loadMyReports() async {
    final user = ref.read(authViewModelProvider).user;
    if (user == null) {
      state = state.copyWith(
        isLoading: false,
        myReports: const [],
        errorMessage: null,
        isSuccess: false,
      );
      return;
    }
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    final result = await ref.read(getMyReportsUsecaseProvider).call(user.email);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (myReports) => state = state.copyWith(isLoading: false, myReports: myReports),
    );
  }

  Future<void> submitReport(
    String title,
    String description,
    String category,
    String location,
    String? imagePath,
  ) async {
    final user = ref.read(authViewModelProvider).user;
    if (user == null) {
      state = state.copyWith(errorMessage: 'Please log in to submit issues');
      return;
    }
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    final report = ReportEntity(
      reportId: '',
      title: title,
      description: description,
      category: category,
      status: 'pending',
      imageUrl: null,
      location: location,
      submittedBy: user.email,
      createdAt: DateTime.now(),
    );
    final params = SubmitReportParams(report: report, imagePath: imagePath);
    final result = await ref.read(submitReportUsecaseProvider).call(params);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (newReport) {
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          reports: [newReport, ...state.reports],
          myReports: [newReport, ...state.myReports],
        );
      },
    );
  }

  void resetState() {
    state = state.copyWith(errorMessage: null, isSuccess: false);
  }
}
