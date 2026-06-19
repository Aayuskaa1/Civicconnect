import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/features/dashboard/presentation/state/bottom_navigation_state.dart';

final bottomNavigationProvider = StateNotifierProvider<BottomNavigationViewModel, BottomNavigationState>((ref) {
  return BottomNavigationViewModel();
});

class BottomNavigationViewModel extends StateNotifier<BottomNavigationState> {
  BottomNavigationViewModel() : super(BottomNavigationState.initial());

  void changeTab(int index) {
    state = state.copyWith(index: index);
  }
}
