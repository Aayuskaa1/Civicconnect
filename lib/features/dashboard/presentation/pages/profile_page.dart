import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:civic_connect/features/complaint/presentation/pages/my_complaints_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  static const Color pastelViolet = Color(0xFFEDE9FE);
  static const Color textDeep = Color(0xFF4338CA);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: pastelViolet,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            CircleAvatar(
              radius: 48,
              backgroundColor: textDeep.withValues(alpha: 0.1),
              child: const Icon(Icons.person, size: 48, color: textDeep),
            ),
            const SizedBox(height: 16),
            Text(
              user?.fullName ?? 'Guest User',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDeep),
            ),
            if (user != null) ...[
              const SizedBox(height: 4),
              Text(
                user.email,
                style: TextStyle(fontSize: 14, color: textDeep.withValues(alpha: 0.6)),
              ),
            ],
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.assignment_outlined, color: textDeep),
              title: const Text('My Complaints'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyComplaintsPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
