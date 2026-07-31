import 'package:dio/dio.dart';

/// Live API smoke — run with:
///   cd frontend && dart run tool/live_api_smoke.dart
Future<void> main() async {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:3001/api/v1/',
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 12),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ),
  );

  final sw = Stopwatch()..start();
  final login = await dio.post(
    'auth/login',
    data: {'email': 'test@example.com', 'password': 'password123'},
  );
  sw.stop();

  if (login.statusCode != 200 || login.data['success'] != true) {
    throw StateError('Login failed: ${login.statusCode} ${login.data}');
  }
  final token = login.data['data']['token'] as String;
  if (token.isEmpty) {
    throw StateError('Login returned empty token');
  }
  // ignore: avoid_print
  print('LOGIN_OK in ${sw.elapsedMilliseconds}ms');

  final reports = await dio.get(
    'reports',
    options: Options(headers: {'Authorization': 'Bearer $token'}),
  );
  if (reports.statusCode != 200 || reports.data['success'] != true) {
    throw StateError('Reports failed: ${reports.statusCode} ${reports.data}');
  }
  final list = reports.data['data'] as List<dynamic>;
  // ignore: avoid_print
  print('REPORTS_OK count=${list.length}');

  if (sw.elapsed > const Duration(seconds: 10)) {
    throw StateError('Login was too slow: ${sw.elapsed}');
  }
  // ignore: avoid_print
  print('SMOKE_PASSED');
}
