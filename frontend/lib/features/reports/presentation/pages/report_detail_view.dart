import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/app/theme/my_theme.dart';
import 'package:civic_connect/app/theme/app_typography.dart';
import 'package:civic_connect/app/theme/app_spacing.dart';
import 'package:civic_connect/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:civic_connect/features/reports/domain/entities/report_entity.dart';
import 'package:civic_connect/features/reports/presentation/view_model/report_view_model.dart';

class ReportDetailView extends ConsumerStatefulWidget {
  final ReportEntity report;

  const ReportDetailView({super.key, required this.report});

  @override
  ConsumerState<ReportDetailView> createState() => _ReportDetailViewState();
}

class _ReportDetailViewState extends ConsumerState<ReportDetailView> {
  late ReportEntity _report;
  bool _updatingStatus = false;

  static const _statusOptions = ['pending', 'in_progress', 'resolved'];

  @override
  void initState() {
    super.initState();
    _report = widget.report;
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

  Future<void> _onStatusChanged(String? status) async {
    if (status == null || status == _report.status) return;
    setState(() => _updatingStatus = true);
    final updated = await ref
        .read(reportViewModelProvider.notifier)
        .updateReportStatus(_report.reportId, status);
    if (!mounted) return;
    setState(() => _updatingStatus = false);
    if (updated != null) {
      setState(() => _report = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to ${_formatStatusText(status)}')),
      );
    } else {
      final error = ref.read(reportViewModelProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Failed to update status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authViewModelProvider).user;
    final isAdmin = (user?.role ?? '').toLowerCase() == 'admin';
    final statusColor = _getStatusColor(_report.status);
    final statusText = _formatStatusText(_report.status);

    Widget buildImageWidget() {
      if (_report.imageUrl == null || _report.imageUrl!.isEmpty) {
        return Container(
          height: 220,
          color: MyTheme.surfaceElevated,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.image_not_supported_outlined,
                  color: MyTheme.textSecondary,
                  size: 48,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'No Image Uploaded',
                  style: AppTypography.caption(MyTheme.textSecondary),
                ),
              ],
            ),
          ),
        );
      }

      final isFile = !_report.imageUrl!.startsWith('http');
      if (isFile) {
        final file = File(_report.imageUrl!);
        if (file.existsSync()) {
          return Image.file(
            file,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
          );
        }
      }

      return Image.network(
        _report.imageUrl!,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 220,
            color: MyTheme.surfaceElevated,
            child: const Center(
              child: Icon(Icons.broken_image_outlined, color: MyTheme.mutedText, size: 48),
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: MyTheme.darkBackground,
      appBar: AppBar(
        title: Text(
          'Report Details',
          style: AppTypography.title(MyTheme.textPrimary),
        ),
        backgroundColor: MyTheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildImageWidget(),
            Padding(
              padding: AppSpacing.pageAll,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: AppDecorations.statusPill(MyTheme.primary),
                        child: Text(
                          _report.category.toUpperCase(),
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
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _report.title,
                    style: AppTypography.headline(MyTheme.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: MyTheme.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Submitted on ${_formatDate(_report.createdAt)}',
                        style: AppTypography.bodySm(MyTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: MyTheme.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          _report.location,
                          style: AppTypography.bodySm(MyTheme.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  if (isAdmin) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Update Status',
                      style: AppTypography.titleSm(MyTheme.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    DropdownButtonFormField<String>(
                      key: ValueKey(_report.status),
                      initialValue: _statusOptions.contains(_report.status)
                          ? _report.status
                          : 'pending',
                      dropdownColor: MyTheme.surface,
                      style: AppTypography.body(MyTheme.textPrimary),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: MyTheme.lightBg,
                      ),
                      items: _statusOptions
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(_formatStatusText(status)),
                            ),
                          )
                          .toList(),
                      onChanged: _updatingStatus ? null : _onStatusChanged,
                    ),
                    if (_updatingStatus) ...[
                      const SizedBox(height: AppSpacing.sm),
                      const LinearProgressIndicator(),
                    ],
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(color: MyTheme.border),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Description',
                    style: AppTypography.titleSm(MyTheme.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _report.description,
                    style: AppTypography.body(MyTheme.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(color: MyTheme.border),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        color: MyTheme.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Reported by: ${_report.submittedBy}',
                        style: AppTypography.bodySm(MyTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
