import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  // Pastel Palette Constants
  static const Color pastelViolet = Color(0xFFEDE9FE);
  static const Color textDeep = Color(0xFF4338CA);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: pastelViolet, // Consistent Pastel Background
      appBar: AppBar(
        title: const Text(
          'My Profile',
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
                color: textDeep.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 64,
                color: textDeep,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Profile Anonymous',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textDeep, // Harmonized with theme
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please log in to your civic account\nto access personalized profile settings.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: textDeep.withOpacity(0.6), // Consistent secondary text
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}