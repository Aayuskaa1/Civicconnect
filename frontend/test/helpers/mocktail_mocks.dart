import 'package:civic_connect/features/auth/domain/repositories/auth_repository.dart';
import 'package:civic_connect/features/reports/domain/repositories/report_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockReportRepository extends Mock implements ReportRepository {}
