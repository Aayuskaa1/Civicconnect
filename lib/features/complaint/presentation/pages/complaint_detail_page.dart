import 'package:flutter/material.dart';

class ComplaintDetailPage extends StatelessWidget {
  final String complaintId;

  const ComplaintDetailPage({super.key, required this.complaintId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complaint Details')),
      body: Center(child: Text('Details and status tracking for complaint: $complaintId')),
    );
  }
}