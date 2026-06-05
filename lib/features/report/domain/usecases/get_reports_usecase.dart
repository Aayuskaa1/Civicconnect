import 'package:dartz/dartz.dart';
import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/core/usecases/app_usecase.dart';
import 'package:civic_connect/features/report/domain/entities/report_entity.dart';
import 'package:civic_connect/features/report/domain/repositories/i_report_repository.dart';

class GetReportsUseCase implements UseCase<Either<Failure, List<ReportEntity>>, NoParams> {
  final IReportRepository _repository;

  GetReportsUseCase(this._repository);

  @override
  Future<Either<Failure, List<ReportEntity>>> call(NoParams params) =>
      _repository.getAllReports();
}
