import 'dart:io';

import 'package:civic_connect/core/api/api_endpoints.dart';
import 'package:civic_connect/core/constants/hive_table_constant.dart';
import 'package:civic_connect/core/providers/shared_prefs_provider.dart';
import 'package:civic_connect/core/services/connectivity/network_info.dart';
import 'package:civic_connect/core/services/storage/token_service.dart';
import 'package:civic_connect/features/auth/data/models/auth_hive_model.dart';
import 'package:civic_connect/features/auth/presentation/state/auth_state.dart';
import 'package:civic_connect/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:civic_connect/features/reports/data/models/report_hive_model.dart';
import 'package:civic_connect/features/reports/presentation/view_model/report_view_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _AllowHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context);
  }
}

class _AlwaysOnline implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
}

class _MemoryTokenService implements TokenService {
  String? _token;

  @override
  Future<void> saveToken(String token) async => _token = token;

  @override
  Future<String?> getToken() async => _token;

  @override
  Future<void> clearToken() async => _token = null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _AllowHttpOverrides();

  late ProviderContainer container;
  late Directory hiveDir;
  late _MemoryTokenService tokenService;

  setUpAll(() async {
    hiveDir = await Directory.systemTemp.createTemp('civic_live_smoke_');
    Hive.init(hiveDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ReportHiveModelAdapter());
    }
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.userBox);
    await Hive.openBox<ReportHiveModel>(HiveTableConstant.reportBox);
    await Hive.openBox<String>('session_box');

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    tokenService = _MemoryTokenService();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        networkInfoProvider.overrideWithValue(_AlwaysOnline()),
        tokenServiceProvider.overrideWithValue(tokenService),
      ],
    );
  });

  tearDownAll(() async {
    container.dispose();
    await Hive.close();
    if (hiveDir.existsSync()) {
      hiveDir.deleteSync(recursive: true);
    }
  });

  test('base URL is simulator localhost', () {
    expect(ApiEndpoints.baseUrl, 'http://127.0.0.1:3000/api/v1/');
  });

  test('live Dio login + reports', () async {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 12),
      ),
    );

    final loginResponse = await dio.post(
      ApiEndpoints.login,
      data: {'email': 'test@example.com', 'password': 'password123'},
    );
    expect(loginResponse.statusCode, 200);
    expect(loginResponse.data['success'], isTrue);
    final token = loginResponse.data['data']['token'] as String;

    final reportsResponse = await dio.get(
      ApiEndpoints.complaints,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    expect(reportsResponse.statusCode, 200);
    expect(reportsResponse.data['success'], isTrue);
    expect(reportsResponse.data['data'], isA<List>());
    expect((reportsResponse.data['data'] as List), isNotEmpty);
  });

  test('AuthViewModel live login finishes under 10s', () async {
    final sw = Stopwatch()..start();
    await container
        .read(authViewModelProvider.notifier)
        .login('test@example.com', 'password123');
    sw.stop();

    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.authenticated, reason: state.errorMessage);
    expect(state.user?.email, 'test@example.com');
    expect(await tokenService.getToken(), isNotEmpty);
    expect(sw.elapsed, lessThan(const Duration(seconds: 10)));
  });

  test('ReportViewModel loads after live login', () async {
    if (container.read(authViewModelProvider).status != AuthStatus.authenticated) {
      await container
          .read(authViewModelProvider.notifier)
          .login('test@example.com', 'password123');
    }
    await container.read(reportViewModelProvider.notifier).loadReports();
    final reportState = container.read(reportViewModelProvider);
    expect(reportState.errorMessage, isNull, reason: reportState.errorMessage);
    expect(reportState.reports, isNotEmpty);
  });
}
