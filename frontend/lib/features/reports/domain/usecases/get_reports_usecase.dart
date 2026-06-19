import 'package:dartz/dartz.dart';
import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/core/usecases/app_usecase.dart';
import 'package:civic_connect/features/reports/domain/entities/report_entity.dart';
import 'package:civic_connect/features/reports/domain/repositories/report_repository.dart';

class GetReportsUsecase implements UsecaseWithoutParams<List<ReportEntity>> {
  final ReportRepository _repository;

  GetReportsUsecase(this._repository);

  @override
  Future<Either<Failure, List<ReportEntity>>> call() {
    return _repository.getReports();
  }
}
