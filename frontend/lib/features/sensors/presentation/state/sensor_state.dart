class ReportSuggestion {
  const ReportSuggestion({
    required this.category,
    required this.title,
    required this.description,
    required this.source,
  });

  final String category;
  final String title;
  final String description;
  final String source;
}

class SensorState {
  const SensorState({
    this.lux,
    this.isDarkArea = false,
    this.ambientThemeMode,
    this.pendingSuggestion,
    this.lastEventMessage,
    this.lightAvailable = true,
    this.motionAvailable = true,
  });

  final double? lux;
  final bool isDarkArea;

  /// When auto ambient theme is active: ThemeMode.dark / light, else null.
  final String? ambientThemeMode;
  final ReportSuggestion? pendingSuggestion;
  final String? lastEventMessage;
  final bool lightAvailable;
  final bool motionAvailable;

  SensorState copyWith({
    double? lux,
    bool? isDarkArea,
    String? ambientThemeMode,
    bool clearAmbientTheme = false,
    ReportSuggestion? pendingSuggestion,
    bool clearSuggestion = false,
    String? lastEventMessage,
    bool clearEventMessage = false,
    bool? lightAvailable,
    bool? motionAvailable,
  }) {
    return SensorState(
      lux: lux ?? this.lux,
      isDarkArea: isDarkArea ?? this.isDarkArea,
      ambientThemeMode: clearAmbientTheme
          ? null
          : (ambientThemeMode ?? this.ambientThemeMode),
      pendingSuggestion: clearSuggestion
          ? null
          : (pendingSuggestion ?? this.pendingSuggestion),
      lastEventMessage: clearEventMessage
          ? null
          : (lastEventMessage ?? this.lastEventMessage),
      lightAvailable: lightAvailable ?? this.lightAvailable,
      motionAvailable: motionAvailable ?? this.motionAvailable,
    );
  }
}
