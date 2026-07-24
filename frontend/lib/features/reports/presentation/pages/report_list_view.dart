import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/app/theme/my_theme.dart';
import 'package:civic_connect/app/theme/app_typography.dart';
import 'package:civic_connect/app/theme/app_spacing.dart';
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

  final List<String> _categories = [
    'All',
    'Maintenance',
    'Water',
    'Electricity',
    'Safety',
    'Lighting',
    'Parking',
    'Noise',
    'Other',
  ];
  final List<String> _statuses = ['All', 'pending', 'in_progress', 'resolved'];

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'maintenance':
        return Icons.handyman_outlined;
      case 'water':
        return Icons.water_drop_outlined;
      case 'electricity':
        return Icons.lightbulb_outline;
      case 'safety':
        return Icons.security;
      case 'lighting':
        return Icons.wb_twilight_outlined;
      case 'parking':
        return Icons.local_parking_outlined;
      case 'noise':
        return Icons.volume_up_outlined;
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
        return MyTheme.mutedText;
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
          'Reports',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: MyTheme.surface,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        category,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? MyTheme.textOnPrimary
                              : MyTheme.textSecondary,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: MyTheme.primary,
                      backgroundColor: MyTheme.surface,
                      side: BorderSide(
                        color: isSelected ? MyTheme.primary : MyTheme.border,
                      ),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _statuses.map((status) {
                  final isSelected = _selectedStatus == status;
                  final label =
                      status == 'All' ? 'All' : _formatStatusText(status);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(
                        label,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                          color: isSelected
                              ? MyTheme.primary
                              : MyTheme.textSecondary,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: MyTheme.primaryLight,
                      backgroundColor: MyTheme.surface,
                      checkmarkColor: MyTheme.primary,
                      side: BorderSide(
                        color: isSelected ? MyTheme.primary : MyTheme.border,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedStatus = status);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1, color: MyTheme.border),
          // Reports Feed List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(reportViewModelProvider.notifier).loadReports();
              },
              color: MyTheme.brandBlue,
              backgroundColor: MyTheme.darkNavy,
              child: reportState.isLoading && reportState.reports.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: MyTheme.brandBlue))
                  : filteredReports.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                            const Center(
                              child: Icon(
                                Icons.list_alt_outlined,
                                size: 64,
                                color: MyTheme.mutedText,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Center(
                              child: Text(
                                'No reports match your filters.',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: MyTheme.mutedText,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MyTheme.radiusLg),
        hoverColor: MyTheme.primaryLight.withValues(alpha: 0.35),
        child: Ink(
          padding: AppSpacing.cardPadding,
          decoration: AppDecorations.card(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: AppDecorations.iconWell(),
                child: Icon(icon, color: MyTheme.primary, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          report.category.toUpperCase(),
                          style: AppTypography.overline(MyTheme.primary),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: AppDecorations.statusPill(statusColor),
                          child: Text(
                            statusText.toUpperCase(),
                            style: AppTypography.overline(statusColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      report.title,
                      style: AppTypography.titleSm(MyTheme.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: MyTheme.textSecondary,
                          size: 14,
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Expanded(
                          child: Text(
                            report.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption(MyTheme.textSecondary),
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
      ),
    );
  }
}
