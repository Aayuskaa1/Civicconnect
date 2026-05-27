import 'package:civic_connect/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'signup_view.dart';
// Assuming AppColors is defined in a global file or accessible
// import 'app_colors.dart'; 

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Pastel Palette Constants
  static const Color pastelIndigo = Color(0xFFE0E7FF);
  static const Color pastelViolet = Color(0xFFEDE9FE);
  static const Color textDeep = Color(0xFF4338CA);

  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pastelViolet, // Global Palette Background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Container
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.hub_outlined, size: 48, color: textDeep),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Civic Connect',
                    style: TextStyle(
                      color: textDeep,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Welcome back. Please log in.',
                    style: TextStyle(fontSize: 16, color: textDeep.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 48),
                  
                  // Login Box
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: pastelIndigo),
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _usernameCtrl,
                          decoration: _inputDecoration('Username', Icons.person_outline),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        const Divider(color: pastelIndigo),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscure,
                          decoration: _inputDecoration('Password', Icons.lock_outline).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: textDeep),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _login,
                      style: FilledButton.styleFrom(
                        backgroundColor: textDeep,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('CONTINUE', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupView())),
                    child: const Text("Don't have an account? Sign Up", style: TextStyle(color: textDeep, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 14, color: textDeep),
      prefixIcon: Icon(icon, size: 20, color: textDeep),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
    );
  }
}