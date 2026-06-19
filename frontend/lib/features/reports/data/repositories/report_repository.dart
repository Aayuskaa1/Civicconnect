import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/core/services/connectivity/network_info.dart';
import 'package:civic_connect/features/reports/data/datasources/report_datasource.dart';
import 'package:civic_connect/features/reports/data/models/report_hive_model.dart';
import 'package:civic_connect/features/reports/domain/entities/report_entity.dart';
import 'package:civic_connect/features/reports/domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDatasource _remoteDataSource;
  final ReportLocalDatasource _localDataSource;
  final NetworkInfo _networkInfo;

  ReportRepositoryImpl({
    required ReportRemoteDatasource remoteDataSource,
    required ReportLocalDatasource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<ReportEntity>>> getReports() async {
    try {
      final isOnline = await _networkInfo.isConnected;
      if (isOnline) {
        try {
          final remoteReports = await _remoteDataSource.getReports();
          // Caching locally
          final hiveModels = remoteReports.map((r) => ReportHiveModel.fromEntity(r)).toList();
          await _localDataSource.saveReports(hiveModels);
          return Right(remoteReports);
        } catch (_) {
          // Fallback to Hive cache if remote fails (e.g. 404 or backend down)
          final localReports = await _localDataSource.getReports();
          return Right(localReports.map((model) => model.toEntity()).toList());
        }
      } else {
        final localReports = await _localDataSource.getReports();
        return Right(localReports.map((model) => model.toEntity()).toList());
      }
    } catch (e) {
      return Left(LocalDatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReportEntity>>> getMyReports(String userId) async {
    try {
      final isOnline = await _networkInfo.isConnected;
      if (isOnline) {
        try {
          final remoteReports = await _remoteDataSource.getMyReports(userId);
          final hiveModels = remoteReports.map((r) => ReportHiveModel.fromEntity(r)).toList();
          await _localDataSource.saveReports(hiveModels);
          return Right(remoteReports);
        } catch (_) {
          final localReports = await _localDataSource.getMyReports(userId);
          return Right(localReports.map((model) => model.toEntity()).toList());
        }
      } else {
        final localReports = await _localDataSource.getMyReports(userId);
        return Right(localReports.map((model) => model.toEntity()).toList());
      }
    } catch (e) {
      return Left(LocalDatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReportEntity>> submitReport(ReportEntity report, String? imagePath) async {
    try {
      final isOnline = await _networkInfo.isConnected;
      if (isOnline) {
        try {
          final submitted = await _remoteDataSource.submitReport(report, imagePath);
          final hiveModel = ReportHiveModel.fromEntity(submitted);
          await _localDataSource.saveReport(hiveModel);
          return Right(submitted);
        } catch (_) {
          // If remote fails, save locally with an ID and imagePath (or URL) and return
          final updatedReport = ReportEntity(
            reportId: report.reportId.isEmpty ? const Uuid().v4() : report.reportId,
            title: report.title,
            description: report.description,
            category: report.category,
            status: report.status,
            imageUrl: imagePath, // save path locally
            location: report.location,
            submittedBy: report.submittedBy,
            createdAt: report.createdAt,
          );
          final hiveModel = ReportHiveModel.fromEntity(updatedReport);
          await _localDataSource.saveReport(hiveModel);
          return Right(updatedReport);
        }
      } else {
        final updatedReport = ReportEntity(
          reportId: report.reportId.isEmpty ? const Uuid().v4() : report.reportId,
          title: report.title,
          description: report.description,
          category: report.category,
          status: report.status,
          imageUrl: imagePath,
          location: report.location,
          submittedBy: report.submittedBy,
          createdAt: report.createdAt,
        );
        final hiveModel = ReportHiveModel.fromEntity(updatedReport);
        await _localDataSource.saveReport(hiveModel);
        return Right(updatedReport);
      }
    } catch (e) {
      return Left(LocalDatabaseFailure(e.toString()));
    }
  }
}
