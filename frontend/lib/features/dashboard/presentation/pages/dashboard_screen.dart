import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/app/theme/my_theme.dart';
import 'package:civic_connect/features/chat/presentation/pages/chat_screen.dart';
import 'package:civic_connect/features/dashboard/presentation/pages/home_screen.dart';
import 'package:civic_connect/features/dashboard/presentation/pages/reports_screen.dart';
import 'package:civic_connect/features/dashboard/presentation/pages/submit_report_screen.dart';
import 'package:civic_connect/features/dashboard/presentation/pages/profile_screen.dart';
import 'package:civic_connect/features/dashboard/presentation/view_models/bottom_navigation_viewmodel.dart';
import 'package:civic_connect/features/sensors/presentation/widgets/sensor_host.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    ReportsScreen(),
    SubmitReportScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(bottomNavigationProvider);

    return SensorHost(
      child: Scaffold(
        body: IndexedStack(
          index: navState.index,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: MyTheme.surface,
            border: const Border(
              top: BorderSide(color: MyTheme.border, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: MyTheme.shadow.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: BottomNavigationBar(
              currentIndex: navState.index,
              onTap: (index) {
                ref.read(bottomNavigationProvider.notifier).changeTab(index);
              },
              backgroundColor: MyTheme.surface,
              selectedItemColor: MyTheme.primary,
              unselectedItemColor: MyTheme.textSecondary,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 10,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.list_alt_outlined),
                  activeIcon: Icon(Icons.list_alt_rounded),
                  label: 'Reports',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle_outline),
                  activeIcon: Icon(Icons.add_circle_rounded),
                  label: 'Submit',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.auto_awesome_outlined),
                  activeIcon: Icon(Icons.auto_awesome),
                  label: 'Ask AI',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
