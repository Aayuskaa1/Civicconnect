import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/features/complaint/presentation/pages/post_complaint_page.dart';

class ReportPage extends ConsumerWidget {
  const ReportPage({super.key});

  static const Color pastelViolet = Color(0xFFEDE9FE);
  static const Color textDeep = Color(0xFF4338CA);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: pastelViolet,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PostComplaintPage()),
        ),
        backgroundColor: textDeep,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Report', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: textDeep.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.rate_review_outlined, size: 64, color: textDeep),
            ),
            const SizedBox(height: 24),
            const Text(
              'Report an Issue',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDeep),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the button below to file a new\ncivic complaint or service request.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: textDeep.withValues(alpha: 0.6),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
