import 'package:dartz/dartz.dart';
import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/features/complaint/data/datasources/complaint_datasource.dart';
import 'package:civic_connect/features/complaint/data/models/complaint_hive_model.dart';
import 'package:civic_connect/features/complaint/domain/entities/complaint_entity.dart';
import 'package:civic_connect/features/complaint/domain/repositories/i_complaint_repository.dart';

class ComplaintRepositoryImpl implements IComplaintRepository {
  final IComplaintDataSource _dataSource;

  ComplaintRepositoryImpl({required IComplaintDataSource dataSource}) : _dataSource = dataSource;

  @override
  Future<Either<Failure, List<ComplaintEntity>>> getComplaintsByUser(String userEmail) async {
    try {
      final complaints = await _dataSource.getComplaintsByUser(userEmail);
      return Right(complaints.map((c) => c.toEntity()).toList());
    } catch (e) {
      return Left(LocalFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ComplaintEntity>> createComplaint(ComplaintEntity entity) async {
    try {
      final model = ComplaintHiveModel.fromEntity(entity);
      await _dataSource.createComplaint(model);
      return Right(model.toEntity());
    } catch (e) {
      return Left(LocalFailure(e.toString()));
    }
  }
}
