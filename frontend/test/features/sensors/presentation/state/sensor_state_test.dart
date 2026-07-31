import 'package:civic_connect/features/sensors/presentation/state/sensor_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('initial SensorState defaults', () {
    const state = SensorState();
    expect(state.lux, isNull);
    expect(state.isDarkArea, isFalse);
    expect(state.pendingSuggestion, isNull);
  });

  test('copyWith updates lux and dark flag', () {
    const state = SensorState();
    final updated = state.copyWith(lux: 12.5, isDarkArea: true);
    expect(updated.lux, 12.5);
    expect(updated.isDarkArea, isTrue);
  });

  test('copyWith clears pending suggestion', () {
    const state = SensorState(
      pendingSuggestion: ReportSuggestion(
        category: 'Lighting',
        title: 'Dark hallway',
        description: 'Low lux',
        source: 'light',
      ),
    );
    final cleared = state.copyWith(clearSuggestion: true);
    expect(cleared.pendingSuggestion, isNull);
  });

  test('copyWith clears event message and ambient theme', () {
    const state = SensorState(
      lastEventMessage: 'Shake detected',
      ambientThemeMode: 'dark',
    );
    final cleared = state.copyWith(
      clearEventMessage: true,
      clearAmbientTheme: true,
    );
    expect(cleared.lastEventMessage, isNull);
    expect(cleared.ambientThemeMode, isNull);
  });

  test('ReportSuggestion holds sensor metadata', () {
    const suggestion = ReportSuggestion(
      category: 'Safety',
      title: 'Bump',
      description: 'Hard jolt',
      source: 'bump',
    );
    expect(suggestion.category, 'Safety');
    expect(suggestion.source, 'bump');
  });
}
