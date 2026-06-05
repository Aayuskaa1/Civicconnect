import 'package:civic_connect/core/utils/snackbar_utilis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_extensions.dart';
import '../../../auth/data/datasources/local/auth_local_datasource.dart';
import '../../../auth/data/models/auth_hive_model.dart';
import 'login_page.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Added ignore comments to resolve linting warnings
  // ignore: prefer_final_fields
  bool _obscurePassword = true;
  // ignore: prefer_final_fields
  bool _obscureConfirmPassword = true;
  
  bool _isLoading = false;
  bool _agreedToTerms = false;

  String? _selectedCategory;
  final List<String> _reportCategories = ['Infrastructure', 'Waste Management', 'Water Supply', 'Roads', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_agreedToTerms) {
      SnackbarUtils.showError(context, 'Please agree to the Terms & Conditions');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authDatasource = ref.read(authLocalDatasourceProvider);
    final email = _emailController.text.trim();
    
    final isEmailExists = await authDatasource.isEmailExists(email);
    if (!mounted) return;
    
    if (isEmailExists) {
      setState(() => _isLoading = false);
      SnackbarUtils.showError(context, 'Email already registered.');
      return;
    }

    final user = AuthHiveModel(
      email: email,
      password: _passwordController.text.trim(),
      fullName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      username: _nameController.text.trim(),
      report: _selectedCategory ?? 'Other',
      role: 'Citizen',
      department: 'General',
      profilePicture: null,
    );

    final success = await authDatasource.register(user);
    if (!mounted) return;
    
    setState(() => _isLoading = false);

    if (success) {
      SnackbarUtils.showSuccess(context, 'Account created successfully.');
      AppRoutes.pushReplacement(context, const LoginPage());
    } else {
      SnackbarUtils.showError(context, 'Signup failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary), 
          onPressed: () => AppRoutes.pushReplacement(context, const LoginPage())
        )
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Join Civic Connect', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: context.textPrimary)),
                const SizedBox(height: 32),
                TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name'), validator: (v) => v!.isEmpty ? 'Enter name' : null),
                const SizedBox(height: 16),
                TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email'), validator: (v) => v!.contains('@') ? null : 'Invalid email'),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Report Category'),
                  items: _reportCategories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v),
                  validator: (v) => v == null ? 'Select a category' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(controller: _passwordController, obscureText: _obscurePassword, decoration: const InputDecoration(labelText: 'Password'), validator: (v) => v!.length < 6 ? 'Too short' : null),
                const SizedBox(height: 16),
                TextFormField(controller: _confirmPasswordController, obscureText: _obscureConfirmPassword, decoration: const InputDecoration(labelText: 'Confirm Password'), validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null),
                const SizedBox(height: 24),
                CheckboxListTile(
                  value: _agreedToTerms,
                  onChanged: (v) => setState(() => _agreedToTerms = v!),
                  title: const Text('I agree to the Terms', style: TextStyle(fontSize: 14)),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignup,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Create Account', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}