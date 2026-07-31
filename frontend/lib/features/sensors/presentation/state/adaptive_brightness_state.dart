/// In-app Adaptive Brightness state driven by **system** screen brightness.
///
/// On iOS this does not use a light sensor (no public lux API). Values come
/// from `UIScreen.main.brightness` via the native bridge.
class AdaptiveBrightnessState {
  const AdaptiveBrightnessState({
    this.enabled = true,
    this.systemBrightness = 0.5,
    this.available = false,
    this.isDarkUi = false,
  });

  /// User toggle ("Adaptive Brightness"), persisted in UserDefaults on iOS.
  final bool enabled;

  /// Latest `UIScreen.main.brightness` in `0.0`–`1.0`.
  final double systemBrightness;

  /// True when the native iOS bridge is available.
  final bool available;

  /// Whether in-app UI should use the dark theme / dim overlay.
  final bool isDarkUi;

  AdaptiveBrightnessState copyWith({
    bool? enabled,
    double? systemBrightness,
    bool? available,
    bool? isDarkUi,
  }) {
    return AdaptiveBrightnessState(
      enabled: enabled ?? this.enabled,
      systemBrightness: systemBrightness ?? this.systemBrightness,
      available: available ?? this.available,
      isDarkUi: isDarkUi ?? this.isDarkUi,
    );
  }
}
