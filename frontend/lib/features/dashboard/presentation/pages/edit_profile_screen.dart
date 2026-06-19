import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:civic_connect/app/theme/my_theme.dart';
import 'package:civic_connect/core/utils/snackbar_utils.dart';
import 'package:civic_connect/features/auth/presentation/state/auth_state.dart';
import 'package:civic_connect/features/auth/presentation/view_model/auth_view_model.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  static const String routeName = '/profile/edit';

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  String? _selectedImagePath;

  bool get _isIosSimulator =>
      Platform.isIOS &&
      Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');

  @override
  void initState() {
    super.initState();
    final user = ref.read(authViewModelProvider).user;
    _fullNameController.text = user?.fullName ?? '';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isIosSimulator && source == ImageSource.camera) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          'Camera is not available in the iOS Simulator. Please use Gallery.',
        );
      }
      return;
    }

    try {
      final PermissionStatus status;
      if (Platform.isIOS) {
        status = PermissionStatus.granted;
      } else {
        status = source == ImageSource.camera
            ? await Permission.camera.request()
            : PermissionStatus.granted;
      }

      if (status.isGranted || status.isLimited) {
        final picker = ImagePicker();
        final picked = await picker.pickImage(source: source, imageQuality: 70);
        if (picked != null && mounted) {
          setState(() => _selectedImagePath = picked.path);
        }
      } else if (mounted) {
        SnackbarUtils.showError(
          context,
          'Permission denied. Could not pick image.',
        );
      }
    } catch (_) {
      if (mounted) {
        final sourceName = source == ImageSource.camera
            ? 'camera'
            : 'photo library';
        SnackbarUtils.showError(
          context,
          'Unable to open $sourceName on this device right now.',
        );
      }
    }
  }

  void _showSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: MyTheme.darkNavy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: MyTheme.civicBlue,
                ),
                title: const Text(
                  'Gallery',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'MontserratRegular',
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: MyTheme.civicBlue),
                title: const Text(
                  'Camera',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'MontserratRegular',
                  ),
                ),
                enabled: !_isIosSimulator,
                onTap: _isIosSimulator
                    ? null
                    : () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
              ),
              if (_isIosSimulator)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    'Camera is unavailable in the iOS Simulator. Use Gallery instead.',
                    style: TextStyle(
                      color: Color(0xFF6B8FAF),
                      fontFamily: 'MontserratRegular',
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(authViewModelProvider.notifier)
        .updateProfile(
          fullName: _fullNameController.text.trim(),
          imagePath: _selectedImagePath,
        );

    if (!mounted) return;

    final authState = ref.read(authViewModelProvider);
    if (authState.status == AuthStatus.error &&
        authState.errorMessage != null) {
      SnackbarUtils.showError(context, authState.errorMessage!);
      return;
    }

    SnackbarUtils.showSuccess(context, 'Profile updated successfully!');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.user;
    final currentPhoto = _selectedImagePath ?? user?.profilePicture;

    Widget avatar = const CircleAvatar(
      radius: 56,
      backgroundColor: Color(0xFF1E293B),
      child: Icon(Icons.person, size: 54, color: Color(0xFF6B8FAF)),
    );

    if (currentPhoto != null && currentPhoto.isNotEmpty) {
      if (currentPhoto.startsWith('http')) {
        avatar = CircleAvatar(
          radius: 56,
          backgroundImage: NetworkImage(currentPhoto),
        );
      } else {
        final file = File(currentPhoto);
        if (file.existsSync()) {
          avatar = CircleAvatar(radius: 56, backgroundImage: FileImage(file));
        }
      }
    }

    return Scaffold(
      backgroundColor: MyTheme.darkBackground,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontFamily: 'MontserratBold',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: MyTheme.darkNavy,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: MyTheme.civicBlue,
                    shape: BoxShape.circle,
                  ),
                  child: avatar,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: OutlinedButton.icon(
                  onPressed: authState.status == AuthStatus.loading
                      ? null
                      : _showSourceDialog,
                  icon: const Icon(Icons.upload),
                  label: const Text(
                    'Upload Image',
                    style: TextStyle(fontFamily: 'MontserratBold'),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _fullNameController,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'MontserratRegular',
                ),
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: Color(0xFF6B8FAF),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: user?.email ?? '',
                readOnly: true,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'MontserratRegular',
                ),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: Color(0xFF6B8FAF),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: user?.role ?? 'User',
                readOnly: true,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'MontserratRegular',
                ),
                decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(
                    Icons.badge_outlined,
                    color: Color(0xFF6B8FAF),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: authState.status == AuthStatus.loading
                    ? null
                    : _saveProfile,
                child: authState.status == AuthStatus.loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                          fontFamily: 'MontserratBold',
                          fontSize: 16,
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
