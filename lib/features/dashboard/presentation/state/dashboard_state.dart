class DashboardState {
  final int currentIndex;

  const DashboardState({this.currentIndex = 0});

  DashboardState copyWith({int? currentIndex}) =>
      DashboardState(currentIndex: currentIndex ?? this.currentIndex);
}
