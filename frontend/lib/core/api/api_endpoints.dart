import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  /// Mac LAN IP for physical devices. Override:
  ///   flutter run --dart-define=USE_LAN=true --dart-define=LAN_HOST=192.168.x.x
  static const String _lanHost = String.fromEnvironment(
    'LAN_HOST',
    defaultValue: '192.168.1.70',
  );

  static const String _webBaseUrl = 'http://127.0.0.1:3000/api/v1/';
  static const String _androidEmulatorBaseUrl = 'http://10.0.2.2:3000/api/v1/';
  static const String _iosSimulatorBaseUrl = 'http://127.0.0.1:3000/api/v1/';
  static String get _lanBaseUrl => 'http://$_lanHost:3000/api/v1/';

  /// USE_LAN=true  → physical iPhone/Android (Mac LAN IP)
  /// USE_LAN=false → iOS Simulator / Android emulator (localhost / 10.0.2.2)
  ///
  /// Defaults to false so Simulator works out of the box.
  /// Physical device launch configs pass USE_LAN=true.
  static const bool _useLan = bool.fromEnvironment('USE_LAN', defaultValue: false);

  static String get baseUrl {
    if (kIsWeb) return _webBaseUrl;
    if (_useLan) return _lanBaseUrl;
    try {
      if (Platform.isAndroid) return _androidEmulatorBaseUrl;
    } catch (_) {}
    return _iosSimulatorBaseUrl;
  }

  static String get serverOrigin {
    final uri = Uri.parse(baseUrl);
    return '${uri.scheme}://${uri.host}:${uri.port}';
  }

  /// Keep connect timeout short so a wrong host fails fast in the UI.
  static const Duration connectionTimeout = Duration(seconds: 8);
  static const Duration receiveTimeout = Duration(seconds: 12);
  static const Duration sendTimeout = Duration(seconds: 12);

  // Shared CivicConnect API (same paths as CivicConnectWeb)
  static const String register = 'auth/register';
  static const String login = 'auth/login';
  static const String whoami = 'auth/whoami';
  static const String updateProfile = 'auth/update';

  static const String complaints = 'complaints';
  static const String myComplaints = 'complaints/me';
  static String complaintDetail(String id) => 'complaints/$id';
  static String updateComplaintAdmin(String id) => 'complaints/$id/admin';

  static const String chat = 'ai/chat';
}
