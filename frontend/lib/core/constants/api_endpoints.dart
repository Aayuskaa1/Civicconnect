import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const String _androidBaseUrl = "http://10.0.2.2:3000/api/v1/";
  static const String _iosBaseUrl = "http://localhost:3000/api/v1/";

  static String get baseUrl {
    if (kIsWeb) {
      return _iosBaseUrl;
    }
    try {
      if (Platform.isAndroid) {
        return _androidBaseUrl;
      }
    } catch (_) {}
    return _iosBaseUrl;
  }

  // Auth endpoints
  static const String login = "auth/login";
  static const String register = "auth/register";

  // Timeout durations
  static const Duration connectionTimeout = Duration(milliseconds: 5000);
  static const Duration receiveTimeout = Duration(milliseconds: 5000);
}
