import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/features/dashboard/presentation/state/dashboard_state.dart';

final dashboardViewModelProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(const DashboardState());

  void updateIndex(int index) => state = state.copyWith(currentIndex: index);
}
