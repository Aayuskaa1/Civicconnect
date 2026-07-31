import 'package:civic_connect/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('LocalDatabaseFailure exposes message', () {
    const failure = LocalDatabaseFailure('Hive write failed');
    expect(failure.message, 'Hive write failed');
  });

  test('ApiFailure exposes message and statusCode', () {
    const failure = ApiFailure(message: 'Unauthorized', statusCode: 401);
    expect(failure.message, 'Unauthorized');
    expect(failure.statusCode, 401);
  });

  test('ApiFailure equality includes statusCode', () {
    const a = ApiFailure(message: 'Bad request', statusCode: 400);
    const b = ApiFailure(message: 'Bad request', statusCode: 400);
    const c = ApiFailure(message: 'Bad request', statusCode: 500);
    expect(a, equals(b));
    expect(a, isNot(equals(c)));
  });

  test('failures with same message compare equal when type matches', () {
    const a = LocalDatabaseFailure('offline');
    const b = LocalDatabaseFailure('offline');
    expect(a, equals(b));
  });
}
