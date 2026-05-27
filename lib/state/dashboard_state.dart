import 'package:flutter/material.dart';
import '../screens/bottom_screens/complaints_screen.dart';
import '../screens/bottom_screens/home_screen.dart';
import '../screens/bottom_screens/profile_screen.dart';
import '../screens/bottom_screens/status_screen.dart';

@immutable
class DashboardState {
  final List<Widget> lstBottomScreens;
  final int currentScreenIndex;

  const DashboardState({
    this.lstBottomScreens = const [],
    this.currentScreenIndex = 0,
  });

  DashboardState.initial()
      : lstBottomScreens = [
          const HomeScreen(),
          const ComplaintsScreen(),
          const StatusScreen(),
          const ProfileScreen(),
        ],
        currentScreenIndex = 0;

  DashboardState copyWith({
    List<Widget>? lstBottomScreens,
    int? currentIndex,
  }) {
    return DashboardState(
      lstBottomScreens: lstBottomScreens ?? this.lstBottomScreens,
      currentScreenIndex: currentIndex ?? this.currentScreenIndex,
    );
  }
}