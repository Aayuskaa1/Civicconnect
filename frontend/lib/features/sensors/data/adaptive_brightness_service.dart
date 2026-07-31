import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Talks to the iOS UIKit [BrightnessMonitor] via platform channels.
///
/// iOS does not expose ambient light sensor lux to apps. On iOS this service
/// reads `UIScreen.main.brightness` and streams updates from
/// `UIScreen.brightnessDidChangeNotification` so the Flutter UI can adapt
/// (theme / overlays) without changing system brightness.
class AdaptiveBrightnessService {
  AdaptiveBrightnessService();

  static const _methodChannel = MethodChannel(
    'com.civicconnect/adaptive_brightness',
  );
  static const _eventChannel = EventChannel(
    'com.civicconnect/adaptive_brightness/stream',
  );

  static bool get isSupported {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  Future<double> getSystemBrightness() async {
    if (!isSupported) return 0.5;
    try {
      final value = await _methodChannel.invokeMethod<double>(
        'getSystemBrightness',
      );
      return (value ?? 0.5).clamp(0.0, 1.0);
    } on MissingPluginException {
      return 0.5;
    } on PlatformException {
      return 0.5;
    }
  }

  Future<bool> getAdaptiveEnabled() async {
    if (!isSupported) {
      return true;
    }
    try {
      final value = await _methodChannel.invokeMethod<bool>(
        'getAdaptiveEnabled',
      );
      return value ?? true;
    } on MissingPluginException {
      return true;
    } on PlatformException {
      return true;
    }
  }

  Future<void> setAdaptiveEnabled(bool enabled) async {
    if (!isSupported) return;
    try {
      await _methodChannel.invokeMethod<void>(
        'setAdaptiveEnabled',
        enabled,
      );
    } on MissingPluginException {
      // No-op on unsupported builds.
    } on PlatformException {
      // Ignore — UI toggle still updates local state.
    }
  }

  /// Live system brightness (`0.0`–`1.0`). Cancelling the subscription stops
  /// the native NotificationCenter observer.
  Stream<double> brightnessStream() {
    if (!isSupported) {
      return Stream<double>.value(0.5);
    }

    return _eventChannel.receiveBroadcastStream().map((event) {
      if (event is num) return event.toDouble().clamp(0.0, 1.0);
      return 0.5;
    });
  }
}
