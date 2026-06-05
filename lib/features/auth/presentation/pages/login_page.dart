import 'package:civic_connect/core/utils/snackbar_utilis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import 'signup_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // Accessing the local datasource to verify Hive storage
      final authDatasource = ref.read(authLocalDatasourceProvider);
      final user = await authDatasource.login(email, password);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (user != null) {
        SnackbarUtils.showSuccess(context, 'Login successful. Welcome to Civic Connect!');
        AppRoutes.pushReplacement(context, const DashboardScreen());
      } else {
        SnackbarUtils.showError(context, 'Invalid email or password');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      SnackbarUtils.showError(context, 'Login failed: ${e.toString()}');
    }
  }

  void _navigateToSignup() => AppRoutes.push(context, const SignupPage());

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textDark;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Civic Connect Logo
                Center(
                  child: SvgPicture.asset(
                    'assets/svg/civic_connect_logo.svg', // Ensure this path is correct
                    width: 200,
                    height: 70,
                    colorFilter: ColorFilter.mode(
                      isDarkMode ? AppColors.darkTextPrimary : AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                Text('Welcome Back!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 8),
                Text('Sign in to your Civic Connect account', style: TextStyle(fontSize: 16, color: secondaryTextColor)),

                const SizedBox(height: 40),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                  validator: (value) => (value == null || !value.contains('@')) ? 'Enter a valid email' : null,
                ),

                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) => (value == null || value.length < 6) ? 'Password must be at least 6 characters' : null,
                ),

                const SizedBox(height: 24),

                // Login Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.authPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 24),

                // Sign up navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ", style: TextStyle(color: secondaryTextColor)),
                    TextButton(
                      onPressed: _navigateToSignup,
                      child: Text('Sign Up', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}