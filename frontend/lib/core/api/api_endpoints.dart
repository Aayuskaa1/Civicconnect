import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  /// Mac LAN IP for physical devices. Override:
  ///   flutter run --dart-define=USE_LAN=true --dart-define=LAN_HOST=192.168.x.x
  static const String _lanHost = String.fromEnvironment(
    'LAN_HOST',
    defaultValue: '192.168.1.76',
  );

  static const String _webBaseUrl = 'http://127.0.0.1:3001/api/v1/';
  static const String _androidEmulatorBaseUrl = 'http://10.0.2.2:3001/api/v1/';
  static const String _iosSimulatorBaseUrl = 'http://127.0.0.1:3001/api/v1/';
  static String get _lanBaseUrl => 'http://$_lanHost:3001/api/v1/';

  /// USE_LAN=true  → physical iPhone/Android (Mac LAN IP)
  /// USE_LAN=false → iOS Simulator / Android emulator (localhost / 10.0.2.2)
  ///
  /// Defaults to true so a physical iPhone (incl. iPhone Mirroring) works
  /// without extra flags. Simulator launches must pass USE_LAN=false.
  static const bool _useLan = bool.fromEnvironment('USE_LAN', defaultValue: true);

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

  /// Rewrites backend media URLs so images work on simulator and physical devices.
  /// Stored URLs often contain `127.0.0.1` from upload time — that fails on a phone.
  static String? resolveMediaUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final trimmed = url.trim();

    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      if (trimmed.startsWith('/')) {
        return '$serverOrigin$trimmed';
      }
      return trimmed; // local file path
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null) return trimmed;

    final host = uri.host.toLowerCase();
    final isLoopback = host == '127.0.0.1' ||
        host == 'localhost' ||
        host == '0.0.0.0' ||
        host == '10.0.2.2' ||
        host == '::1';

    if (!isLoopback) return trimmed;

    return uri.replace(
      host: Uri.parse(serverOrigin).host,
      port: Uri.parse(serverOrigin).port,
    ).toString();
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
