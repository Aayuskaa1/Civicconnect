import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/features/sensors/data/adaptive_brightness_service.dart';
import 'package:civic_connect/features/sensors/presentation/state/adaptive_brightness_state.dart';

final adaptiveBrightnessServiceProvider = Provider<AdaptiveBrightnessService>(
  (ref) => AdaptiveBrightnessService(),
);

final adaptiveBrightnessProvider = StateNotifierProvider<
    AdaptiveBrightnessController, AdaptiveBrightnessState>((ref) {
  final service = ref.watch(adaptiveBrightnessServiceProvider);
  final controller = AdaptiveBrightnessController(service);
  ref.onDispose(controller.dispose);
  return controller;
});

/// Adapts CivicConnect UI to system brightness (iOS) — never sets it.
///
/// iOS has no public ambient lux API. We observe system brightness changes
/// (including those caused by the OS auto-brightness sensor path) and map
/// them to in-app theme / overlay adjustments only.
class AdaptiveBrightnessController
    extends StateNotifier<AdaptiveBrightnessState> {
  AdaptiveBrightnessController(this._service)
      : super(const AdaptiveBrightnessState()) {
    unawaited(_bootstrap());
  }

  /// Below this system brightness, Adaptive Brightness switches to dark UI.
  static const double darkUiThreshold = 0.35;

  final AdaptiveBrightnessService _service;
  StreamSubscription<double>? _sub;

  Future<void> _bootstrap() async {
    final available = AdaptiveBrightnessService.isSupported;
    final enabled = await _service.getAdaptiveEnabled();
    final brightness = await _service.getSystemBrightness();

    state = AdaptiveBrightnessState(
      available: available,
      enabled: enabled,
      systemBrightness: brightness,
      isDarkUi: enabled && brightness < darkUiThreshold,
    );

    if (!available) return;

    _sub = _service.brightnessStream().listen(_onBrightness);
  }

  void _onBrightness(double brightness) {
    final dark = state.enabled && brightness < darkUiThreshold;
    state = state.copyWith(
      systemBrightness: brightness,
      isDarkUi: dark,
      available: true,
    );
  }

  Future<void> setEnabled(bool enabled) async {
    await _service.setAdaptiveEnabled(enabled);
    final dark = enabled && state.systemBrightness < darkUiThreshold;
    state = state.copyWith(enabled: enabled, isDarkUi: dark);
  }

  /// Theme mode for [MaterialApp] when adaptive mode is active.
  ThemeMode get themeMode {
    if (!state.enabled || !state.available) return ThemeMode.light;
    return state.isDarkUi ? ThemeMode.dark : ThemeMode.light;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
