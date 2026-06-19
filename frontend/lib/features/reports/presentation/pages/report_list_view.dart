import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/app/theme/my_theme.dart';
import 'package:civic_connect/features/reports/domain/entities/report_entity.dart';
import 'package:civic_connect/features/reports/presentation/pages/report_detail_view.dart';
import 'package:civic_connect/features/reports/presentation/view_model/report_view_model.dart';

class ReportListView extends ConsumerStatefulWidget {
  const ReportListView({super.key});

  @override
  ConsumerState<ReportListView> createState() => _ReportListViewState();
}

class _ReportListViewState extends ConsumerState<ReportListView> {
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';

  final List<String> _categories = ['All', 'Road', 'Water', 'Electricity', 'Safety', 'Other'];
  final List<String> _statuses = ['All', 'pending', 'in_progress', 'resolved'];

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

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportViewModelProvider);

    // Apply client-side filtering based on chips/dropdown selected
    final filteredReports = reportState.reports.where((report) {
      final matchesCategory = _selectedCategory == 'All' ||
          report.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesStatus = _selectedStatus == 'All' ||
          report.status.toLowerCase() == _selectedStatus.toLowerCase();
      return matchesCategory && matchesStatus;
    }).toList();

    return Scaffold(
      backgroundColor: MyTheme.darkBackground,
      appBar: AppBar(
        title: const Text(
          'Community Reports',
          style: TextStyle(fontFamily: 'MontserratBold', fontWeight: FontWeight.bold),
        ),
        backgroundColor: MyTheme.darkNavy,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Horizontal Category Filter
          Container(
            color: MyTheme.darkNavy,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
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
                          fontFamily: isSelected ? 'MontserratBold' : 'MontserratRegular',
                          color: isSelected ? Colors.white : const Color(0xFF6B8FAF),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: MyTheme.civicBlue,
                      backgroundColor: const Color(0xFF1E293B),
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
          ),
          // Status Filter Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter by Status:',
                  style: TextStyle(
                    fontFamily: 'MontserratRegular',
                    color: Color(0xFF6B8FAF),
                    fontSize: 13,
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedStatus,
                  dropdownColor: MyTheme.darkNavy,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.filter_list, color: MyTheme.civicBlue),
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'MontserratBold',
                    fontSize: 13,
                  ),
                  items: _statuses.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status == 'All' ? 'All Statuses' : _formatStatusText(status)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedStatus = val);
                    }
                  },
                ),
              ],
            ),
          ),
          // Reports Feed List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(reportViewModelProvider.notifier).loadReports();
              },
              color: MyTheme.civicBlue,
              backgroundColor: MyTheme.darkNavy,
              child: reportState.isLoading && reportState.reports.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: MyTheme.civicBlue))
                  : filteredReports.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                            const Center(
                              child: Icon(
                                Icons.list_alt_outlined,
                                size: 64,
                                color: Color(0xFF6B8FAF),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Center(
                              child: Text(
                                'No reports match your filters.',
                                style: TextStyle(
                                  fontFamily: 'MontserratBold',
                                  fontSize: 16,
                                  color: Color(0xFF6B8FAF),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: filteredReports.length,
                          itemBuilder: (context, index) {
                            final report = filteredReports[index];
                            return _ReportCard(
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
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ReportEntity report;
  final IconData icon;
  final Color statusColor;
  final String statusText;
  final VoidCallback onTap;

  const _ReportCard({
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
                child: Icon(icon, color: MyTheme.civicBlue, size: 28),
              ),
              const SizedBox(width: 16),
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
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            statusText.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'MontserratBold',
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      report.title,
                      style: const TextStyle(
                        fontFamily: 'MontserratBold',
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Color(0xFF6B8FAF), size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            report.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'MontserratRegular',
                              color: Color(0xFF6B8FAF),
                              fontSize: 12,
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
