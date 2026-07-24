import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:civic_connect/app/theme/my_theme.dart';
import 'package:civic_connect/app/theme/app_typography.dart';
import 'package:civic_connect/app/theme/app_spacing.dart';
import 'package:civic_connect/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:civic_connect/features/dashboard/presentation/pages/edit_profile_screen.dart';
import 'package:civic_connect/features/reports/domain/entities/report_entity.dart';
import 'package:civic_connect/features/reports/presentation/pages/report_detail_view.dart';
import 'package:civic_connect/features/reports/presentation/view_model/report_view_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final user = ref.read(authViewModelProvider).user;
      if (user != null) {
        ref.read(reportViewModelProvider.notifier).loadMyReports();
      }
    });
  }

  void _openEditProfile() {
    Navigator.pushNamed(context, EditProfileScreen.routeName);
  }

  String _formatStatus(String status) {
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return MyTheme.statusPending;
      case 'in_progress':
        return MyTheme.statusActive;
      case 'resolved':
        return MyTheme.statusResolved;
      default:
        return MyTheme.textSecondary;
    }
  }

  Widget _buildAvatar(String? profilePicture) {
    if (profilePicture != null && profilePicture.isNotEmpty) {
      final isNetwork = profilePicture.startsWith('http');
      if (isNetwork) {
        return CircleAvatar(
          radius: 48,
          backgroundImage: NetworkImage(profilePicture),
        );
      }
      final file = File(profilePicture);
      if (file.existsSync()) {
        return CircleAvatar(
          radius: 48,
          backgroundImage: FileImage(file),
        );
      }
    }
    return const CircleAvatar(
      radius: 48,
      backgroundColor: MyTheme.primaryLight,
      child: Icon(Icons.person_rounded, size: 48, color: MyTheme.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final reportState = ref.watch(reportViewModelProvider);
    final user = authState.user;

    final myReports = reportState.myReports;
    final totalSubmitted = myReports.length;
    final totalResolved = myReports
        .where((r) => r.status.toLowerCase() == 'resolved')
        .length;
    final totalPending = myReports
        .where((r) => r.status.toLowerCase() == 'pending')
        .length;
    final displayName = (user?.fullName.trim().isNotEmpty ?? false)
        ? user!.fullName
        : (user?.email ?? 'Profile');
    final roleLabel = (user?.role ?? 'user').toLowerCase() == 'admin'
        ? 'Admin'
        : 'Resident';

    return Scaffold(
      backgroundColor: MyTheme.background,
      appBar: AppBar(
        backgroundColor: MyTheme.surface,
        elevation: 0,
        title: Text(
          'My Profile',
          style: AppTypography.title(MyTheme.textPrimary),
        ),
        actions: [
          IconButton(
            onPressed: _openEditProfile,
            icon: const Icon(Icons.edit_outlined, color: MyTheme.primary),
            tooltip: 'Edit Profile',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: MyTheme.border),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (user != null) {
            await ref.read(reportViewModelProvider.notifier).loadMyReports();
          }
        },
        color: MyTheme.primary,
        backgroundColor: MyTheme.surface,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.pageAll,
          children: [
            Container(
              padding: AppSpacing.cardPadding,
              decoration: AppDecorations.card(),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: MyTheme.primary,
                            width: 2.5,
                          ),
                        ),
                        child: _buildAvatar(user?.profilePicture),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Material(
                          color: MyTheme.primary,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _openEditProfile,
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.xs),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: MyTheme.surface,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                size: 14,
                                color: MyTheme.textOnPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    displayName,
                    textAlign: TextAlign.center,
                    style: AppTypography.title(MyTheme.textPrimary),
                  ),
                  if (user?.username != null &&
                      user!.username!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '@${user.username}',
                      style: AppTypography.bodySm(MyTheme.textSecondary),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    user?.email ?? '',
                    style: AppTypography.caption(MyTheme.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: AppDecorations.statusPill(MyTheme.primary),
                    child: Text(
                      roleLabel.toUpperCase(),
                      style: AppTypography.overline(MyTheme.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: AppSpacing.cardPadding,
              decoration: AppDecorations.card(),
              child: Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      label: 'Submitted',
                      value: totalSubmitted,
                      color: MyTheme.primary,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 44,
                    color: MyTheme.border,
                  ),
                  Expanded(
                    child: _StatItem(
                      label: 'Resolved',
                      value: totalResolved,
                      color: MyTheme.statusResolved,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 44,
                    color: MyTheme.border,
                  ),
                  Expanded(
                    child: _StatItem(
                      label: 'Pending',
                      value: totalPending,
                      color: MyTheme.statusPending,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'My submitted issues',
                    style: AppTypography.titleSm(MyTheme.textPrimary),
                  ),
                ),
                Text(
                  '${myReports.length}',
                  style: AppTypography.caption(MyTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (reportState.isLoading && myReports.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Center(
                  child: CircularProgressIndicator(color: MyTheme.primary),
                ),
              )
            else if (myReports.isEmpty)
              Container(
                width: double.infinity,
                padding: AppSpacing.cardPadding,
                decoration: AppDecorations.card(),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: AppDecorations.iconWell(),
                      child: const Icon(
                        Icons.inbox_outlined,
                        color: MyTheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'No issues yet',
                      style: AppTypography.titleSm(MyTheme.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Reports you submit will appear here.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySm(MyTheme.textSecondary),
                    ),
                  ],
                ),
              )
            else
              ...myReports.map(
                (report) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _MyReportTile(
                    report: report,
                    statusColor: _getStatusColor(report.status),
                    statusText: _formatStatus(report.status),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReportDetailView(report: report),
                        ),
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value', style: AppTypography.title(color)),
        const SizedBox(height: AppSpacing.xxs),
        Text(label, style: AppTypography.caption(MyTheme.textSecondary)),
      ],
    );
  }
}

class _MyReportTile extends StatelessWidget {
  final ReportEntity report;
  final Color statusColor;
  final String statusText;
  final VoidCallback onTap;

  const _MyReportTile({
    required this.report,
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
        child: Ink(
          padding: AppSpacing.cardPadding,
          decoration: AppDecorations.card(),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: AppDecorations.iconWell(),
                child: const Icon(
                  Icons.description_outlined,
                  color: MyTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleSm(MyTheme.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '${report.category} • ${_formatDate(report.createdAt)}',
                      style: AppTypography.caption(MyTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
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
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
