import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/app/theme/my_theme.dart';
import 'package:civic_connect/app/theme/app_typography.dart';
import 'package:civic_connect/app/theme/app_spacing.dart';
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
    'Maintenance',
    'Water',
    'Electricity',
    'Safety',
    'Lighting',
    'Parking',
    'Noise',
  ];

  String _getFirstName(String? fullName) {
    final trimmedName = fullName?.trim() ?? '';
    if (trimmedName.isEmpty) return 'Resident';
    return trimmedName.split(RegExp(r'\s+')).first;
  }

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

    final recentReports = reportState.reports.where((report) {
      if (_selectedCategory == 'All') return true;
      return report.category.toLowerCase() == _selectedCategory.toLowerCase();
    }).toList();

    final pendingCount = reportState.reports
        .where((r) => r.status.toLowerCase() == 'pending')
        .length;
    final resolvedCount = reportState.reports
        .where((r) => r.status.toLowerCase() == 'resolved')
        .length;

    return Scaffold(
      backgroundColor: MyTheme.darkBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: MyTheme.brandBlue,
          backgroundColor: MyTheme.darkNavy,
          onRefresh: () =>
              ref.read(reportViewModelProvider.notifier).loadReports(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CivicConnect',
                              style: AppTypography.title(MyTheme.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Hello, $userName',
                              style: AppTypography.bodySm(MyTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: MyTheme.textSecondary,
                        ),
                        onPressed: _handleLogout,
                        tooltip: 'Logout',
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: MyTheme.surface,
                      borderRadius: BorderRadius.circular(MyTheme.radiusLg),
                      border: Border.all(color: MyTheme.border),
                      boxShadow: MyTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YOUR BUILDING',
                          style: AppTypography.overline(MyTheme.primary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'See something wrong?',
                          style: AppTypography.title(MyTheme.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Report maintenance, water, power, safety, parking, or noise issues.',
                          style: AppTypography.bodySm(MyTheme.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ref
                                  .read(bottomNavigationProvider.notifier)
                                  .changeTab(2);
                            },
                            icon: const Icon(Icons.add_rounded, size: 20),
                            label: const Text('Report an issue'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: () {
                              ref
                                  .read(bottomNavigationProvider.notifier)
                                  .changeTab(3);
                            },
                            icon: const Icon(Icons.auto_awesome, size: 18),
                            label: const Text('Ask AI for help'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          label: 'Open',
                          value: '$pendingCount',
                          color: MyTheme.statusPending,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatTile(
                          label: 'Resolved',
                          value: '$resolvedCount',
                          color: MyTheme.statusResolved,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatTile(
                          label: 'Total',
                          value: '${reportState.reports.length}',
                          color: MyTheme.brandBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Text(
                    'Categories',
                    style: AppTypography.titleSm(MyTheme.textPrimary),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      return ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = category);
                          }
                        },
                        labelStyle: TextStyle(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? MyTheme.textOnPrimary
                              : MyTheme.textSecondary,
                          fontSize: 13,
                        ),
                        selectedColor: MyTheme.primary,
                        backgroundColor: MyTheme.surface,
                        side: BorderSide(
                          color: isSelected
                              ? MyTheme.primary
                              : MyTheme.border,
                        ),
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      );
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Recent reports',
                          style: AppTypography.titleSm(MyTheme.textPrimary),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ref
                              .read(bottomNavigationProvider.notifier)
                              .changeTab(1);
                        },
                        child: Text(
                          'View all',
                          style: AppTypography.button(MyTheme.primary).copyWith(
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (reportState.isLoading && recentReports.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: MyTheme.brandBlue),
                  ),
                )
              else if (recentReports.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyFeed(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final report = recentReports[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ReportFeedCard(
                            report: report,
                            icon: _getCategoryIcon(report.category),
                            statusColor: _getStatusColor(report.status),
                            statusText: _formatStatusText(report.status),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ReportDetailView(report: report),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      childCount: recentReports.length > 6
                          ? 6
                          : recentReports.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTypography.title(color)),
          const SizedBox(height: AppSpacing.xxs),
          Text(label, style: AppTypography.caption(MyTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.apartment_outlined,
              size: 56,
              color: MyTheme.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No reports yet',
              style: AppTypography.title(MyTheme.textPrimary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Issues reported in your apartment complex will show up here.',
              textAlign: TextAlign.center,
              style: AppTypography.body(MyTheme.textSecondary),
            ),
          ],
        ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MyTheme.radiusLg),
        hoverColor: MyTheme.primaryLight.withValues(alpha: 0.35),
        splashColor: MyTheme.primaryLight.withValues(alpha: 0.5),
        child: Ink(
          padding: AppSpacing.cardPadding,
          decoration: AppDecorations.card(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: AppDecorations.iconWell(),
                child: Icon(icon, color: MyTheme.primary, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            report.category.toUpperCase(),
                            style: AppTypography.overline(MyTheme.primary),
                          ),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
    );
  }
}
