import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const Color pastelViolet = Color(0xFFEDE9FE);
  static const Color textDeep = Color(0xFF4338CA);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: pastelViolet,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: textDeep.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.space_dashboard_outlined, size: 64, color: textDeep),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Activity Yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDeep),
            ),
            const SizedBox(height: 8),
            Text(
              'Your submitted community issues and\nupdates will appear right here.',
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
