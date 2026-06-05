import 'package:dartz/dartz.dart';
import 'package:civic_connect/core/error/failures.dart';
import 'package:civic_connect/features/complaint/domain/entities/complaint_entity.dart';

abstract class IComplaintRepository {
  Future<Either<Failure, List<ComplaintEntity>>> getComplaintsByUser(String userEmail);
  Future<Either<Failure, ComplaintEntity>> createComplaint(ComplaintEntity entity);
}
