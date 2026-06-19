import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/app/theme/my_theme.dart';
import 'package:civic_connect/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:civic_connect/features/reports/domain/entities/report_entity.dart';
import 'package:civic_connect/features/reports/presentation/pages/report_detail_view.dart';
import 'package:civic_connect/features/reports/presentation/view_model/report_view_model.dart';
import 'package:civic_connect/features/dashboard/presentation/view_models/bottom_navigation_viewmodel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Road',
    'Water',
    'Electricity',
    'Safety',
  ];

  String _getFirstName(String? fullName) {
    final trimmedName = fullName?.trim() ?? '';
    if (trimmedName.isEmpty) {
      return 'User';
    }

    return trimmedName.split(RegExp(r'\s+')).first;
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'road':
        return Icons.add_road_outlined;
      case 'water':
        return Icons.water_drop_outlined;
      case 'electricity':
        return Icons.lightbulb_outline;
      case 'safety':
        return Icons.security;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return MyTheme.statusPending;
      case 'in_progress':
        return MyTheme.statusActive;
      case 'resolved':
        return MyTheme.statusResolved;
      default:
        return Colors.grey;
    }
  }

  String _formatStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      default:
        return status;
    }
  }

  Future<void> _handleLogout() async {
    await ref.read(authViewModelProvider.notifier).logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final reportState = ref.watch(reportViewModelProvider);
    final userName = _getFirstName(authState.user?.fullName);

    // Filter recent reports based on selected category chip
    final recentReports = reportState.reports.where((report) {
      if (_selectedCategory == 'All') return true;
      return report.category.toLowerCase() == _selectedCategory.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: MyTheme.darkBackground,
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            fontFamily: 'MontserratBold',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: MyTheme.darkNavy,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Greeting pill
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Hello, $userName 👋',
                  style: const TextStyle(
                    fontFamily: 'MontserratBold',
                    color: MyTheme.darkNavy,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          // Category chips header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'Browse by Category',
              style: TextStyle(
                fontFamily: 'MontserratBold',
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Category chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        fontFamily: isSelected
                            ? 'MontserratBold'
                            : 'MontserratRegular',
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF6B8FAF),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: MyTheme.civicBlue,
                    backgroundColor: MyTheme.darkNavy,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = category);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          // Recent Activity Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Reports Feed',
                  style: TextStyle(
                    fontFamily: 'MontserratBold',
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to reports tab
                    ref.read(bottomNavigationProvider.notifier).changeTab(1);
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      fontFamily: 'MontserratBold',
                      color: MyTheme.civicBlue,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Feed list
          Expanded(
            child: recentReports.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: MyTheme.civicBlue.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.space_dashboard_outlined,
                            size: 64,
                            color: MyTheme.civicBlue,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'No Activity Yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'MontserratBold',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your submitted community issues and\nupdates will appear right here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B8FAF),
                            height: 1.6,
                            fontFamily: 'MontserratRegular',
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: recentReports.length > 5
                        ? 5
                        : recentReports.length, // show max 5 recent reports
                    itemBuilder: (context, index) {
                      final report = recentReports[index];
                      return _ReportFeedCard(
                        report: report,
                        icon: _getCategoryIcon(report.category),
                        statusColor: _getStatusColor(report.status),
                        statusText: _formatStatusText(report.status),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReportDetailView(report: report),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ReportFeedCard extends StatelessWidget {
  final ReportEntity report;
  final IconData icon;
  final Color statusColor;
  final String statusText;
  final VoidCallback onTap;

  const _ReportFeedCard({
    required this.report,
    required this.icon,
    required this.statusColor,
    required this.statusText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: MyTheme.darkNavy,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: MyTheme.civicBlue, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          report.category.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'MontserratBold',
                            color: MyTheme.civicBlue,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusText.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'MontserratBold',
                              color: statusColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'MontserratBold',
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFF6B8FAF),
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            report.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'MontserratRegular',
                              color: Color(0xFF6B8FAF),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
