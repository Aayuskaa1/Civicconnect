import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:civic_connect/features/complaint/presentation/pages/complaint_detail_page.dart';
import 'package:civic_connect/features/complaint/presentation/view_model/complaint_view_model.dart';

class MyComplaintsPage extends ConsumerStatefulWidget {
  const MyComplaintsPage({super.key});

  @override
  ConsumerState<MyComplaintsPage> createState() => _MyComplaintsPageState();
}

class _MyComplaintsPageState extends ConsumerState<MyComplaintsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authViewModelProvider).user;
      if (user != null) {
        ref.read(complaintViewModelProvider.notifier).loadComplaints(user.email);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final complaintState = ref.watch(complaintViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Complaints')),
      body: complaintState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : complaintState.complaints.isEmpty
              ? const Center(child: Text('No complaints submitted yet.'))
              : ListView.builder(
                  itemCount: complaintState.complaints.length,
                  itemBuilder: (context, index) {
                    final complaint = complaintState.complaints[index];
                    return ListTile(
                      title: Text(complaint.title),
                      subtitle: Text('${complaint.category} • ${complaint.status}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ComplaintDetailPage(complaintId: complaint.complaintId),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
