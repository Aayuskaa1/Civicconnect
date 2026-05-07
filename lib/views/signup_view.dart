import 'package:flutter/material.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();
  final _fnameCtrl = TextEditingController();
  final _lnameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  
  String? _gender;
  bool _obscure = true;
  final List<String> _genders = ['Male', 'Female', 'Other'];

  final Color primarySlate = const Color(0xFF334155); 
  final Color accentSlate = const Color(0xFF64748B);  
  final Color borderSlate = const Color(0xFFE2E8F0);
  final Color backgroundSlate = const Color(0xFFF8FAFC);  

  @override
  void dispose() {
    _fnameCtrl.dispose();
    _lnameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // --- NEW: Validation Logic ---
  void _handleSignup() {
    if (_formKey.currentState!.validate()) {
      // If all fields are valid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing Account...')),
      );
      // Navigate back or to login
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundSlate,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primarySlate, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Form(
          key: _formKey, // Key used to trigger validation
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Join Community',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: primarySlate, 
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create an account to start contributing.',
                textAlign: TextAlign.center,
                style: TextStyle(color: accentSlate, fontSize: 16),
              ),
              const SizedBox(height: 32),
              
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderSlate),
                ),
                child: Column(
                  children: [
                    _buildField('First Name', Icons.person_outline, _fnameCtrl),
                    const SizedBox(height: 16),
                    _buildField('Last Name', Icons.person_outline, _lnameCtrl),
                    const SizedBox(height: 16),
                    
                    DropdownButtonFormField<String>(
                      value: _gender,
                      icon: Icon(Icons.expand_more, color: accentSlate),
                      decoration: _inputDecoration('Gender', Icons.wc_outlined),
                      items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                      onChanged: (v) => setState(() => _gender = v),
                      // Validator for Dropdown
                      validator: (value) => value == null ? 'Please select gender' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildField('Username', Icons.alternate_email, _usernameCtrl),
                    const SizedBox(height: 16),
                    _buildField('Email', Icons.email_outlined, _emailCtrl, isEmail: true),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      decoration: _inputDecoration('Password', Icons.lock_outline).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, 
                            color: accentSlate, 
                            size: 18
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      // --- Password Validator ---
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 6) {
                          return 'Must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _handleSignup, // Trigger validation function
                  style: FilledButton.styleFrom(
                    backgroundColor: primarySlate,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'CREATE ACCOUNT',
                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, IconData icon, TextEditingController ctrl, {bool isEmail = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      decoration: _inputDecoration(label, icon),
      // --- General Empty Check Validator ---
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        if (isEmail && !value.contains('@')) {
          return 'Enter a valid email';
        }
        return null;
      },
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: accentSlate, size: 20),
      labelStyle: TextStyle(color: accentSlate, fontSize: 14),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      // Error styling
      errorStyle: const TextStyle(fontSize: 11, color: Colors.redAccent),
    );
  }
}