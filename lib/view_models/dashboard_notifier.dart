import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/dashboard_state.dart';

// Definition representing a single civic ticket item
class TicketModel {
  final String id;
  final String title;
  final String status;
  final double progress;

  const TicketModel({
    required this.id,
    required this.title,
    required this.status,
    required this.progress,
  });
}

class DashboardNotifier extends Notifier<DashboardState> {
  // Hardcoded initial data list reflecting active community feedback
  final List<TicketModel> _tickets = [
    const TicketModel(id: "#342145", title: "Lack of Clean Drinking Water", status: "New", progress: 0.0),
    const TicketModel(id: "#342146", title: "Poor Waste Management", status: "In Progress", progress: 0.80),
    const TicketModel(id: "#342147", title: "Traffic Problems", status: "Solved", progress: 1.0),
    const TicketModel(id: "#342148", title: "Lack of Public Health Facilities", status: "Pending", progress: 0.0),
  ];

  List<TicketModel> get tickets => List.unmodifiable(_tickets);

  @override
  DashboardState build() {
    // Sets initial state when provider initializes
    return DashboardState.initial();
  }

  // Updates the current visible tab index window
  void updateIndex(int newIndex) {
    state = state.copyWith(currentIndex: newIndex);
  }

  // Method stub for creating new tickets from the application form
  void addNewTicket(String title, String category, String description) {
    final newId = "#${342149 + _tickets.length}";
    _tickets.insert(
      0,
      TicketModel(id: newId, title: title, status: "New", progress: 0.0),
    );
    // Refresh the state to let UI know a new ticket was introduced
    state = state.copyWith();
  }
}

// Global provider declaration to tap into from your views
final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(() {
  return DashboardNotifier();
});