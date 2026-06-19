import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/app/theme/my_theme.dart';
import 'package:civic_connect/features/dashboard/presentation/pages/home_screen.dart';
import 'package:civic_connect/features/dashboard/presentation/pages/reports_screen.dart';
import 'package:civic_connect/features/dashboard/presentation/pages/submit_report_screen.dart';
import 'package:civic_connect/features/dashboard/presentation/pages/profile_screen.dart';
import 'package:civic_connect/features/dashboard/presentation/view_models/bottom_navigation_viewmodel.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    ReportsScreen(),
    SubmitReportScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(bottomNavigationProvider);

    return Scaffold(
      body: IndexedStack(
        index: navState.index,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navState.index,
        onTap: (index) {
          ref.read(bottomNavigationProvider.notifier).changeTab(index);
        },
        backgroundColor: Colors.white,
        selectedItemColor: MyTheme.civicBlue,
        unselectedItemColor: const Color(0xFF6B8FAF),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontFamily: 'MontserratBold', fontSize: 11, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontFamily: 'MontserratRegular', fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Submit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
