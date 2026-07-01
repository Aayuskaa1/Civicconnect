import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const String _androidBaseUrl = "http://10.0.2.2:3000/api/v1/";
  static const String _iosBaseUrl = "http://192.168.1.74:3000/api/v1/";

  static String get baseUrl {
    if (kIsWeb) return _iosBaseUrl;
    try {
      if (Platform.isAndroid) return _androidBaseUrl;
    } catch (_) {}
    return _iosBaseUrl;
  }

  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth endpoints
  static const String register = "auth/register";
  static const String login = "auth/login";
  static const String profile = "auth/profile";
  static const String profilePicture = "auth/profile-picture";

  // Reports endpoints
  static const String reports = "reports";
  static String getMyReports(String userId) => "reports/user/$userId";
  static String getReportDetail(String reportId) => "reports/$reportId";
  static String updateReportStatus(String reportId) => "reports/$reportId/status";
}
