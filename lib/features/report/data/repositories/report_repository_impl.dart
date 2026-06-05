import 'package:dartz/dartz.dart';
import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/features/report/data/datasources/report_datasource.dart';
import 'package:civic_connect/features/report/data/models/report_hive_model.dart';
import 'package:civic_connect/features/report/domain/entities/report_entity.dart';
import 'package:civic_connect/features/report/domain/repositories/i_report_repository.dart';

class ReportRepositoryImpl implements IReportRepository {
  final IReportDataSource _dataSource;

  ReportRepositoryImpl({required IReportDataSource dataSource}) : _dataSource = dataSource;

  @override
  Future<Either<Failure, List<ReportEntity>>> getAllReports() async {
    try {
      final reports = await _dataSource.getAllReports();
      return Right(reports.map((r) => r.toEntity()).toList());
    } catch (e) {
      return Left(LocalFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReportEntity>> createReport(ReportEntity entity) async {
    try {
      final model = ReportHiveModel.fromEntity(entity);
      await _dataSource.createReport(model);
      return Right(model.toEntity());
    } catch (e) {
      return Left(LocalFailure(e.toString()));
    }
  }
}
