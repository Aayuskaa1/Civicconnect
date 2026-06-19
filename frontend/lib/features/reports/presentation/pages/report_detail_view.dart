import 'dart:io';
import 'package:flutter/material.dart';
import 'package:civic_connect/app/theme/my_theme.dart';
import 'package:civic_connect/features/reports/domain/entities/report_entity.dart';

class ReportDetailView extends StatelessWidget {
  final ReportEntity report;

  const ReportDetailView({super.key, required this.report});

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
    final statusColor = _getStatusColor(report.status);
    final statusText = _formatStatusText(report.status);

    Widget buildImageWidget() {
      if (report.imageUrl == null || report.imageUrl!.isEmpty) {
        return Container(
          height: 200,
          color: const Color(0xFF1E293B),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported_outlined, color: Color(0xFF6B8FAF), size: 48),
                SizedBox(height: 8),
                Text(
                  'No Image Uploaded',
                  style: TextStyle(
                    fontFamily: 'MontserratRegular',
                    color: Color(0xFF6B8FAF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final isFile = !report.imageUrl!.startsWith('http');
      if (isFile) {
        final file = File(report.imageUrl!);
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
        report.imageUrl!,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 220,
            color: const Color(0xFF1E293B),
            child: const Center(
              child: Icon(Icons.broken_image_outlined, color: Color(0xFF6B8FAF), size: 48),
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: MyTheme.darkBackground,
      appBar: AppBar(
        title: const Text(
          'Report Details',
          style: TextStyle(fontFamily: 'MontserratBold', fontWeight: FontWeight.bold),
        ),
        backgroundColor: MyTheme.darkNavy,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildImageWidget(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: MyTheme.civicBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          report.category.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'MontserratBold',
                            color: MyTheme.civicBlue,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusText.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'MontserratBold',
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    report.title,
                    style: const TextStyle(
                      fontFamily: 'MontserratBold',
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Color(0xFF6B8FAF), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Submitted on ${_formatDate(report.createdAt)}',
                        style: const TextStyle(
                          fontFamily: 'MontserratRegular',
                          color: Color(0xFF6B8FAF),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: Color(0xFF6B8FAF), size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          report.location,
                          style: const TextStyle(
                            fontFamily: 'MontserratRegular',
                            color: Color(0xFF6B8FAF),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFF1E293B)),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontFamily: 'MontserratBold',
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.description,
                    style: const TextStyle(
                      fontFamily: 'MontserratRegular',
                      fontSize: 15,
                      color: Color(0xFFE2E8F0),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFF1E293B)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, color: Color(0xFF6B8FAF), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Reported by: ${report.submittedBy}',
                        style: const TextStyle(
                          fontFamily: 'MontserratRegular',
                          fontSize: 13,
                          color: Color(0xFF6B8FAF),
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
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
