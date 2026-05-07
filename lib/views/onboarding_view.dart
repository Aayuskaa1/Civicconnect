import 'package:flutter/material.dart';
import 'login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingPage {
  final Widget visual;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.visual,
    required this.title,
    required this.description,
  });
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _controller = PageController();
  int _index = 0;

  // --- VIBRANT PALETTE ---
  final Color primaryNavy = const Color(0xFF0F172A); 
  final Color electricIndigo = const Color(0xFF6366F1); 
  final Color accentBlue = const Color(0xFF38BDF8); 
  final Color successGreen = const Color(0xFF10B981); 

  late final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      visual: _buildVisualBadge(Icons.add_task_rounded, label: "NEW TICKET", badgeColor: electricIndigo),
      title: 'Report Issues',
      description: 'Snap a photo of potholes or broken lights. Start a service request in seconds.',
    ),
    _OnboardingPage(
      visual: _buildVisualBadge(Icons.insights_rounded, label: "IN PROGRESS", badgeColor: accentBlue),
      title: 'Track Progress',
      description: 'Get real-time status updates as city staff reviews and assigns your tickets.',
    ),
    _OnboardingPage(
      visual: _buildVisualBadge(Icons.how_to_reg_rounded, label: "RESOLVED", badgeColor: successGreen),
      title: 'Civic Impact',
      description: 'See the difference you make. Join thousands building a better community.',
    ),
  ];

  Widget _buildVisualBadge(IconData icon, {required String label, required Color badgeColor}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: badgeColor.withOpacity(0.15),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Icon(icon, size: 80, color: badgeColor),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: badgeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: badgeColor.withOpacity(0.2)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: badgeColor,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, anim, secAnim) => const LoginView(),
        transitionsBuilder: (context, anim, secAnim, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _pages.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "CIVIC CONNECT",
                    style: TextStyle(
                      fontWeight: FontWeight.w900, 
                      fontSize: 14, 
                      color: primaryNavy,
                      letterSpacing: -0.5
                    ),
                  ),
                  TextButton(
                    onPressed: _goToLogin,
                    child: Text('SKIP', style: TextStyle(color: electricIndigo, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                itemCount: _pages.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _pages[i].visual,
                        const SizedBox(height: 50),
                        Text(
                          _pages[i].title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: primaryNavy,
                            letterSpacing: -1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _pages[i].description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16, 
                            color: Color(0xFF475569), 
                            height: 1.6,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Pagination Dots
                  Row(
                    children: List.generate(_pages.length, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      height: 8,
                      width: i == _index ? 32 : 8,
                      decoration: BoxDecoration(
                        color: i == _index ? electricIndigo : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                  ),

                  // Updated Action Button
                  GestureDetector(
                    onTap: () {
                      if (isLast) {
                        _goToLogin();
                      } else {
                        _controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 64,
                      width: isLast ? 200 : 64, // Increased width for "GET STARTED"
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [electricIndigo, primaryNavy],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: electricIndigo.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          )
                        ]
                      ),
                      child: Center(
                        child: isLast
                          ? const Text(
                              "GET STARTED", 
                              style: TextStyle(
                                color: Colors.white, 
                                fontWeight: FontWeight.w900, 
                                letterSpacing: 1.2
                              )
                            )
                          : const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}