import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:civic_connect/app/theme/my_theme.dart';
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final reportState = ref.watch(reportViewModelProvider);
    final user = authState.user;

    // Filter Stats
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

    Widget buildAvatar() {
      if (user?.profilePicture != null && user!.profilePicture!.isNotEmpty) {
        final isNetwork = user.profilePicture!.startsWith('http');
        if (isNetwork) {
          return CircleAvatar(
            radius: 54,
            backgroundImage: NetworkImage(user.profilePicture!),
          );
        } else {
          final file = File(user.profilePicture!);
          if (file.existsSync()) {
            return CircleAvatar(radius: 54, backgroundImage: FileImage(file));
          }
        }
      }
      return const CircleAvatar(
        radius: 54,
        backgroundColor: Color(0xFF1E293B),
        child: Icon(Icons.person, size: 54, color: Color(0xFF6B8FAF)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F1E2D),
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontFamily: 'MontserratBold',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: MyTheme.darkNavy,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _openEditProfile,
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (user != null) {
            await ref.read(reportViewModelProvider.notifier).loadMyReports();
          }
        },
        color: MyTheme.civicBlue,
        backgroundColor: MyTheme.darkNavy,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              // Avatar
              Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: MyTheme.civicBlue,
                        shape: BoxShape.circle,
                      ),
                      child: buildAvatar(),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _openEditProfile,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: MyTheme.accentOrange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // User Info
              Center(
                child: Text(
                  displayName,
                  style: const TextStyle(
                    fontFamily: 'MontserratBold',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (user?.username != null && user!.username!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    '@${user.username}',
                    style: const TextStyle(
                      fontFamily: 'MontserratBold',
                      fontSize: 14,
                      color: MyTheme.accentOrange,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Center(
                child: Text(
                  user?.email ?? 'email@example.com',
                  style: const TextStyle(
                    fontFamily: 'MontserratRegular',
                    fontSize: 13,
                    color: Color(0xFF6B8FAF),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: OutlinedButton.icon(
                  onPressed: _openEditProfile,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text(
                    'Edit Profile',
                    style: TextStyle(fontFamily: 'MontserratBold'),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Stats Row
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MyTheme.darkNavy,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('SUBMITTED', totalSubmitted, Colors.white),
                    _buildStatItem(
                      'RESOLVED',
                      totalResolved,
                      MyTheme.statusResolved,
                    ),
                    _buildStatItem(
                      'PENDING',
                      totalPending,
                      MyTheme.statusPending,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // My Reports List Header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'My Submitted Issues',
                  style: TextStyle(
                    fontFamily: 'MontserratBold',
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // My reports list
              reportState.isLoading && myReports.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: MyTheme.civicBlue,
                        ),
                      ),
                    )
                  : myReports.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          'You have not submitted any issues yet.',
                          style: TextStyle(
                            fontFamily: 'MontserratRegular',
                            color: Color(0xFF6B8FAF),
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: myReports.length,
                      itemBuilder: (context, index) {
                        final report = myReports[index];
                        return _MyReportTile(
                          report: report,
                          statusColor: _getStatusColor(report.status),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ReportDetailView(report: report),
                              ),
                            );
                          },
                        );
                      },
                    ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontFamily: 'MontserratExtraBold',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'MontserratBold',
            fontSize: 10,
            color: Color(0xFF6B8FAF),
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _MyReportTile extends StatelessWidget {
  final ReportEntity report;
  final Color statusColor;
  final VoidCallback onTap;

  const _MyReportTile({
    required this.report,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: MyTheme.darkNavy,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          report.title,
          style: const TextStyle(
            fontFamily: 'MontserratBold',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          '${report.category} • ${_formatDate(report.createdAt)}',
          style: const TextStyle(
            fontFamily: 'MontserratRegular',
            color: Color(0xFF6B8FAF),
            fontSize: 12,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            report.status.toUpperCase(),
            style: TextStyle(
              fontFamily: 'MontserratBold',
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
