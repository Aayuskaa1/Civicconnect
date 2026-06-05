import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComplaintsScreen extends ConsumerWidget {
  const ComplaintsScreen({super.key});

  // Pastel Palette Constants
  static const Color pastelIndigo = Color(0xFFE0E7FF);
  static const Color pastelViolet = Color(0xFFEDE9FE);
  static const Color textDeep = Color(0xFF4338CA);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: pastelViolet, // Consistent background
      appBar: AppBar(
        title: const Text(
          'File Complaint',
          style: TextStyle(fontWeight: FontWeight.bold, color: textDeep),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: textDeep),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: textDeep.withValues(alpha: 0.1), // Consistent with your theme
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.rate_review_outlined,
                size: 64,
                color: textDeep,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Active Forms',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textDeep, // Harmonized with theme
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Form submissions are currently locked.\nCheck back later to report a civic problem.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: textDeep.withValues(alpha: 0.6), // Consistent with other screens
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}