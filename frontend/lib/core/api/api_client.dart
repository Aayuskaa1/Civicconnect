import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:civic_connect/core/api/api_endpoints.dart';
import 'package:civic_connect/core/services/storage/token_service.dart';

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

class ApiClient {
  final Dio _dio;
  final TokenService _tokenService;

  ApiClient(this._dio, this._tokenService) {
    _dio.options = BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: ApiEndpoints.connectionTimeout,
      receiveTimeout: ApiEndpoints.receiveTimeout,
      sendTimeout: ApiEndpoints.sendTimeout,
      headers: {
        // Do not force application/json globally — multipart uploads need
        // multipart/form-data with a boundary (Dio sets that for FormData).
        'Accept': 'application/json',
      },
    );

    _dio.interceptors.add(_AuthInterceptor(_tokenService));
    _dio.interceptors.add(_ErrorInterceptor(_tokenService));

    // Keep retries modest. Auth paths never retry — connection failures to a
    // wrong host (stale LAN IP / USE_LAN mismatch) previously spun the login
    // UI for ~60s+ (3 retries × 15s connectTimeout + backoff delays).
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        retries: 1,
        retryDelays: const [Duration(milliseconds: 600)],
        retryEvaluator: (error, attempt) {
          final path = error.requestOptions.path;
          if (_isAuthPath(path)) return false;

          // Do not retry unreachable-host errors — retries only mask bad URL config.
          if (error.type == DioExceptionType.connectionError) return false;

          return RetryInterceptor.defaultRetryEvaluator(error, attempt);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );
    }
  }

  static bool _isAuthPath(String path) {
    return path.contains(ApiEndpoints.login) ||
        path.contains(ApiEndpoints.register);
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final opts = options ?? Options();
      if (_isAuthPath(path)) {
        opts.disableRetry = true;
      }
      if (data is! FormData) {
        opts.contentType ??= Headers.jsonContentType;
      }
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: opts,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final opts = options ?? Options();
      if (data is! FormData) {
        opts.contentType ??= Headers.jsonContentType;
      }
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: opts,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final opts = options ?? Options();
      if (data is! FormData) {
        opts.contentType ??= Headers.jsonContentType;
      }
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: opts,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> uploadFile(
    String path,
    String filePath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      return await _dio.post(path, data: formData, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        return Exception(data['message']);
      }
      return Exception('Server error: ${e.response?.statusCode}');
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception(
          'Connection timeout. Is the backend running? '
          'Simulator: USE_LAN=false. Device: USE_LAN=true + LAN_HOST.',
        );
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Server response timeout.');
      case DioExceptionType.connectionError:
        return Exception(
          'Could not connect to backend server (${ApiEndpoints.baseUrl}). '
          'Make sure backend is running and dart-defines match your device.',
        );
      default:
        return Exception('Network error: ${e.message}');
    }
  }
}

class _AuthInterceptor extends Interceptor {
  final TokenService _tokenService;

  _AuthInterceptor(this._tokenService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final path = options.path;
    if (path.contains(ApiEndpoints.login) || path.contains(ApiEndpoints.register)) {
      handler.next(options);
      return;
    }

    // Avoid `async void` interceptors — awaiting secure storage there can stall Dio.
    _tokenService.getToken().then((token) {
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    }).catchError((Object error, StackTrace stackTrace) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
          stackTrace: stackTrace,
        ),
      );
    });
  }
}

class _ErrorInterceptor extends Interceptor {
  final TokenService _tokenService;

  _ErrorInterceptor(this._tokenService);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    _tokenService.clearToken().whenComplete(() {
      globalNavigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
      handler.next(err);
    });
  }
}
