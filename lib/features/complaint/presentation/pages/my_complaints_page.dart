import 'package:flutter/material.dart';

class MyComplaintsPage extends StatelessWidget {
  const MyComplaintsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Complaints')),
      body: const Center(child: Text('List of my submitted complaints')),
    );
  }
}