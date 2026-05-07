import 'dart:async';
import 'package:flutter/material.dart';
import 'onboarding_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    // Timer to transition after 2 seconds
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingView()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primarySlate = Color(0xFF334155);

    return Scaffold(
      backgroundColor: primarySlate,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Using your folder 'assests' with images subfolder
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assests/images/help_desk.jpg', 
                height: 120,
                width: 120,
                fit: BoxFit.cover,
                // If the image fails to load, show a placeholder icon
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_not_supported_rounded, 
                    color: Colors.white54, 
                    size: 80
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'CIVIC CONNECT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w300,
                letterSpacing: 4.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'COMMUNITY HELP DESK',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}