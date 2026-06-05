import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComplaintDetailPage extends ConsumerWidget {
  final String complaintId;

  const ComplaintDetailPage({super.key, required this.complaintId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complaint Details')),
      body: Center(
        child: Text('Details and status tracking for complaint: $complaintId'),
      ),
    );
  }
}
