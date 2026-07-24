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
          'Report building issues and help keep your complex running smoothly.',
      'icon': Icons.apartment_outlined,
    },
    {
      'title': 'Report Issues Easily',
      'desc':
          'Snap photos of leaks, power issues, safety concerns, parking problems, or noise. Submit them to building management.',
      'icon': Icons.report_problem_outlined,
    },
    {
      'title': 'Ask AI Anytime',
      'desc':
          'Not sure which category to pick or how statuses work? Open Ask AI for quick tips.',
      'icon': Icons.auto_awesome,
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
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: MyTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'For your complex',
                          style: TextStyle(
                            fontSize: 12,
                            color: MyTheme.mutedText,
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
                            fontWeight: FontWeight.w700,
                            color: MyTheme.brandBlue,
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
                                color: MyTheme.surfaceElevated,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: MyTheme.brandBlue.withValues(
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
                                      color: MyTheme.surfaceElevated,
                                    ),
                                  ),
                                  child: Icon(
                                    data['icon'] as IconData,
                                    size: 72,
                                    color: MyTheme.brandBlue,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Text(
                                  data['title'] as String,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 26,
                                    color: MyTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  data['desc'] as String,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: MyTheme.mutedText,
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
                    border: Border.all(color: MyTheme.surfaceElevated),
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
                                  ? MyTheme.brandBlue
                                  : MyTheme.disabled,
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
                            color: MyTheme.brandBlue,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: MyTheme.brandBlue.withValues(
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
                                  fontWeight: FontWeight.w700,
                                  color: MyTheme.textOnPrimary,
                                ),
                              ),
                              if (!isLastPage) ...[
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: MyTheme.textOnPrimary,
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
