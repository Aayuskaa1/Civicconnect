import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:civic_connect/features/dashboard/presentation/pages/explore_page.dart';
import 'package:civic_connect/features/dashboard/presentation/pages/home_page.dart';
import 'package:civic_connect/features/dashboard/presentation/pages/notifications_page.dart';
import 'package:civic_connect/features/dashboard/presentation/pages/profile_page.dart';
import 'package:civic_connect/features/dashboard/presentation/pages/report_page.dart';
import 'package:civic_connect/features/dashboard/presentation/view_model/dashboard_view_model.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  static const Color pastelIndigo = Color(0xFFE0E7FF);
  static const Color textDeep = Color(0xFF4338CA);

  static const _pages = [
    HomePage(),
    ExplorePage(),
    ReportPage(),
    NotificationsPage(),
    ProfilePage(),
  ];

  static const _labels = ['Home', 'Explore', 'Report', 'Alerts', 'Profile'];

  Future<void> _handleLogout() async {
    final user = ref.read(authViewModelProvider).user;
    if (user == null) return;
    await ref.read(authViewModelProvider.notifier).logout(user.email);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardViewModelProvider);

    ref.listen(authViewModelProvider, (previous, next) {
      if (next.error != null && next.error!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_labels[dashboardState.currentIndex]),
        backgroundColor: pastelIndigo,
        foregroundColor: textDeep,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: IndexedStack(
        index: dashboardState.currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: dashboardState.currentIndex,
        onDestinationSelected: (index) {
          ref.read(dashboardViewModelProvider.notifier).updateIndex(index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.report_outlined), selectedIcon: Icon(Icons.report), label: 'Report'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
