import 'package:flutter/material.dart';
import 'package:civic_connect/app/theme/my_theme.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Welcome to CivicConnect',
      'desc':
          'Your direct bridge to active citizenship and local community engagement. Report issues and join hands to improve our home.',
      'icon': Icons.handshake_outlined,
    },
    {
      'title': 'Report Issues Easily',
      'desc':
          'Snap photos of potholes, public trash piles, or broken streetlights. Submit reports instantly directly to city officials.',
      'icon': Icons.report_problem_outlined,
    },
    {
      'title': 'Track & See Change',
      'desc':
          'Monitor the progress of your reports in real-time. Witness direct action and see how you can make a neighborhood impact.',
      'icon': Icons.trending_up,
    },
  ];

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _onboardingData.length - 1;

    return Scaffold(
      backgroundColor: MyTheme.darkBackground,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [MyTheme.darkNavy, MyTheme.darkBackground],
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'CivicConnect',
                          style: TextStyle(
                            fontFamily: 'MontserratExtraBold',
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Community Help Desk',
                          style: TextStyle(
                            fontFamily: 'MontserratRegular',
                            fontSize: 12,
                            color: Color(0xFF6B8FAF),
                          ),
                        ),
                      ],
                    ),
                    if (!isLastPage)
                      TextButton(
                        onPressed: _goToLogin,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontFamily: 'MontserratBold',
                            color: MyTheme.civicBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    final data = _onboardingData[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 36,
                            ),
                            decoration: BoxDecoration(
                              color: MyTheme.darkNavy,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: const Color(0xFF1E293B),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: MyTheme.civicBlue.withValues(
                                    alpha: 0.12,
                                  ),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: MyTheme.darkBackground,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                  child: Icon(
                                    data['icon'] as IconData,
                                    size: 72,
                                    color: MyTheme.civicBlue,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Text(
                                  data['title'] as String,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'MontserratExtraBold',
                                    fontSize: 26,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  data['desc'] as String,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'MontserratRegular',
                                    fontSize: 14,
                                    color: Color(0xFF6B8FAF),
                                    height: 1.7,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: MyTheme.darkNavy,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          _onboardingData.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(right: 6),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? MyTheme.civicBlue
                                  : const Color(0xFF334155),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (isLastPage) {
                            _goToLogin();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.symmetric(
                            horizontal: isLastPage ? 28 : 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: MyTheme.civicBlue,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: MyTheme.civicBlue.withValues(
                                  alpha: 0.24,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Text(
                                isLastPage ? 'Get Started' : 'Next',
                                style: const TextStyle(
                                  fontFamily: 'MontserratBold',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (!isLastPage) ...[
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
