import 'dart:async';
import 'package:flutter/material.dart';
import 'onboarding_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  // Pastel Palette Constants
  static const Color pastelIndigo = Color(0xFFE0E7FF);
  static const Color pastelViolet = Color(0xFFEDE9FE);
  static const Color textDeep = Color(0xFF4338CA);

  @override
  void initState() {
    super.initState();
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
    return Scaffold(
      body: Container(
        // Applying the Pastel Gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [pastelViolet, pastelIndigo],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white.withOpacity(0.5),
                  child: Image.asset(
                    'assets/images/help_desk.jpg',
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.hub_outlined,
                        color: textDeep,
                        size: 80,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'CIVIC CONNECT',
                style: TextStyle(
                  color: textDeep,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'COMMUNITY HELP DESK',
                style: TextStyle(
                  color: textDeep.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}