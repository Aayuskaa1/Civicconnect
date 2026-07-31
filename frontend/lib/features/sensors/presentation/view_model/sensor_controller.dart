import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light_sensor/light_sensor.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:civic_connect/features/sensors/presentation/state/sensor_state.dart';

final sensorControllerProvider =
    StateNotifierProvider<SensorController, SensorState>((ref) {
  final controller = SensorController();
  ref.onDispose(controller.dispose);
  return controller;
});

/// Light (Android lux / sim demos) + Accelerometer for CivicConnect.
///
/// Adaptive Brightness on iOS is handled separately by
/// [AdaptiveBrightnessController] via system brightness — iOS has no lux API.
class SensorController extends StateNotifier<SensorState> {
  SensorController() : super(const SensorState());

  int _nextEventId() => state.eventId + 1;

  static const double lowLuxThreshold = 25;
  static const double shakeMagnitude = 14;
  static const double bumpMagnitude = 28;
  static const Duration suggestionCooldown = Duration(minutes: 3);
  static const Duration shakeCooldown = Duration(seconds: 2);
  static const Duration bumpCooldown = Duration(seconds: 8);

  StreamSubscription<int>? _lightSub;
  StreamSubscription<UserAccelerometerEvent>? _accelSub;

  DateTime? _lastLowLightPrompt;
  DateTime? _lastShakeAt;
  DateTime? _lastBumpAt;
  int _shakeHits = 0;
  DateTime? _shakeWindowStart;
  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    await _startLightSensor();
    await _startAccelerometer();
  }

  Future<void> _startLightSensor() async {
    if (kIsWeb) {
      state = state.copyWith(lightAvailable: false);
      return;
    }

    try {
      final hasSensor = await LightSensor.hasSensor();
      if (!hasSensor) {
        state = state.copyWith(lightAvailable: false);
        return;
      }

      _lightSub = LightSensor.luxStream().listen(
        (lux) => _onLux(lux.toDouble()),
        onError: (_) {
          state = state.copyWith(lightAvailable: false);
        },
        cancelOnError: true,
      );
      state = state.copyWith(lightAvailable: true);
    } on MissingPluginException {
      state = state.copyWith(lightAvailable: false);
    } catch (_) {
      state = state.copyWith(lightAvailable: false);
    }
  }

  Future<void> _startAccelerometer() async {
    if (kIsWeb) {
      state = state.copyWith(motionAvailable: false);
      return;
    }

    try {
      _accelSub = userAccelerometerEventStream(
        samplingPeriod: SensorInterval.uiInterval,
      ).listen(
        _onAccel,
        onError: (_) {
          state = state.copyWith(motionAvailable: false);
        },
      );
    } catch (_) {
      state = state.copyWith(motionAvailable: false);
    }
  }

  void _onLux(double lux) {
    final isDark = lux < lowLuxThreshold;
    final themeMode = isDark ? 'dark' : 'light';

    state = state.copyWith(
      lux: lux,
      isDarkArea: isDark,
      ambientThemeMode: themeMode,
      lightAvailable: true,
    );

    if (!isDark) return;

    final now = DateTime.now();
    if (_lastLowLightPrompt != null &&
        now.difference(_lastLowLightPrompt!) < suggestionCooldown) {
      return;
    }
    if (state.pendingSuggestion != null) return;

    _lastLowLightPrompt = now;
    state = state.copyWith(
      pendingSuggestion: ReportSuggestion(
        category: 'Lighting',
        title: 'Poor lighting in hallway / stairwell',
        description:
            'Ambient light sensor detected very low brightness '
            '(${lux.toStringAsFixed(0)} lux). This area may need better '
            'lighting for resident safety.',
        source: 'light',
      ),
      lastEventMessage:
          'Low light detected (${lux.toStringAsFixed(0)} lux). Consider a Safety / Lighting report.',
      eventId: _nextEventId(),
    );
  }

  void _onAccel(UserAccelerometerEvent event) {
    final magnitude = math.sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );
    final now = DateTime.now();

    if (magnitude >= bumpMagnitude) {
      if (_lastBumpAt == null ||
          now.difference(_lastBumpAt!) >= bumpCooldown) {
        _lastBumpAt = now;
        if (state.pendingSuggestion == null) {
          state = state.copyWith(
            pendingSuggestion: const ReportSuggestion(
              category: 'Safety',
              title: 'Possible impact / unsafe area',
              description:
                  'A hard bump or jolt was detected on the device. '
                  'If this relates to stairs, uneven flooring, or a fall risk, '
                  'please file a Safety report.',
              source: 'bump',
            ),
            lastEventMessage:
                'Hard bump detected. You can report a safety concern.',
            eventId: _nextEventId(),
          );
        }
      }
      return;
    }

    if (magnitude < shakeMagnitude) return;

    _shakeWindowStart ??= now;
    if (now.difference(_shakeWindowStart!) > const Duration(milliseconds: 900)) {
      _shakeWindowStart = now;
      _shakeHits = 0;
    }
    _shakeHits++;

    if (_shakeHits < 3) return;
    if (_lastShakeAt != null &&
        now.difference(_lastShakeAt!) < shakeCooldown) {
      return;
    }

    _lastShakeAt = now;
    _shakeHits = 0;
    _shakeWindowStart = null;

    state = state.copyWith(
      pendingSuggestion: const ReportSuggestion(
        category: 'Other',
        title: '',
        description: '',
        source: 'shake',
      ),
      lastEventMessage: 'Shake detected — opening Report an issue.',
      eventId: _nextEventId(),
    );
  }

  void clearSuggestion() {
    state = state.copyWith(clearSuggestion: true, clearEventMessage: true);
  }

  void clearEventMessage() {
    state = state.copyWith(clearEventMessage: true);
  }

  void simulateLowLight({double lux = 8}) {
    _lastLowLightPrompt = null;
    state = state.copyWith(clearSuggestion: true);
    _onLux(lux);
  }

  void simulateShake() {
    _lastShakeAt = null;
    _shakeHits = 0;
    _shakeWindowStart = null;
    state = state.copyWith(clearSuggestion: true, clearEventMessage: true);
    state = state.copyWith(
      pendingSuggestion: const ReportSuggestion(
        category: 'Other',
        title: '',
        description: '',
        source: 'shake',
      ),
      lastEventMessage: 'Shake detected — opening Report an issue.',
      eventId: _nextEventId(),
    );
  }

  void simulateBump() {
    _lastBumpAt = null;
    state = state.copyWith(clearSuggestion: true, clearEventMessage: true);
    state = state.copyWith(
      pendingSuggestion: const ReportSuggestion(
        category: 'Safety',
        title: 'Possible impact / unsafe area',
        description:
            'A hard bump or jolt was detected on the device. '
            'If this relates to stairs, uneven flooring, or a fall risk, '
            'please file a Safety report.',
        source: 'bump',
      ),
      lastEventMessage: 'Hard bump detected. You can report a safety concern.',
      eventId: _nextEventId(),
    );
  }

  @override
  void dispose() {
    _lightSub?.cancel();
    _accelSub?.cancel();
    super.dispose();
  }
}
