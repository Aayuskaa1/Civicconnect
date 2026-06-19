class BottomNavigationState {
  final int index;

  const BottomNavigationState({required this.index});

  factory BottomNavigationState.initial() => const BottomNavigationState(index: 0);

  BottomNavigationState copyWith({int? index}) {
    return BottomNavigationState(index: index ?? this.index);
  }
}
