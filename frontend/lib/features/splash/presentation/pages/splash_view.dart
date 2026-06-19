import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/app/theme/my_theme.dart';
import 'package:civic_connect/features/auth/presentation/view_model/auth_view_model.dart';

class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    _navigateToNext();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final isLoggedIn = await ref
        .read(authViewModelProvider.notifier)
        .checkAutoLogin();
    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.darkBackground,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [MyTheme.darkNavy, MyTheme.darkBackground],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        color: MyTheme.darkNavy,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFF1E293B)),
                        boxShadow: [
                          BoxShadow(
                            color: MyTheme.civicBlue.withValues(alpha: 0.16),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.hub_outlined,
                        size: 68,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'CivicConnect',
                      style: TextStyle(
                        fontFamily: 'MontserratExtraBold',
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Connect. Report. Change.',
                      style: TextStyle(
                        fontFamily: 'MontserratItalic',
                        fontSize: 14,
                        color: Color(0xFF6B8FAF),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: MyTheme.darkNavy,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFF1E293B)),
                      ),
                      child: const Text(
                        'Community Help Desk',
                        style: TextStyle(
                          fontFamily: 'MontserratBold',
                          fontSize: 11,
                          color: MyTheme.civicBlue,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    const CircularProgressIndicator(color: MyTheme.civicBlue),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
