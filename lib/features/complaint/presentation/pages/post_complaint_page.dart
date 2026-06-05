import 'package:flutter/material.dart';

class PostComplaintPage extends StatelessWidget {
  const PostComplaintPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Complaint')),
      body: const Center(child: Text('Complaint submission form (Title, Description, Category, Image)')),
    );
  }
}