import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:civic_connect/app/theme/my_theme.dart';
import 'package:civic_connect/app/theme/app_typography.dart';
import 'package:civic_connect/app/theme/app_spacing.dart';
import 'package:civic_connect/core/api/api_endpoints.dart';
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
        final sourceName =
            source == ImageSource.camera ? 'camera' : 'photo library';
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
      backgroundColor: MyTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MyTheme.radiusLg),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: MyTheme.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Update photo',
                  style: AppTypography.titleSm(MyTheme.textPrimary),
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: AppDecorations.iconWell(),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      color: MyTheme.primary,
                    ),
                  ),
                  title: Text(
                    'Gallery',
                    style: AppTypography.titleSm(MyTheme.textPrimary),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  enabled: !_isIosSimulator,
                  leading: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: AppDecorations.iconWell(),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: _isIosSimulator
                          ? MyTheme.disabled
                          : MyTheme.primary,
                    ),
                  ),
                  title: Text(
                    'Camera',
                    style: AppTypography.titleSm(
                      _isIosSimulator
                          ? MyTheme.textSecondary
                          : MyTheme.textPrimary,
                    ),
                  ),
                  onTap: _isIosSimulator
                      ? null
                      : () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        },
                ),
                if (_isIosSimulator) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Camera is unavailable in the iOS Simulator. Use Gallery instead.',
                    style: AppTypography.caption(MyTheme.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref.read(authViewModelProvider.notifier).updateProfile(
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
    final currentPhoto =
        _selectedImagePath ?? ApiEndpoints.resolveMediaUrl(user?.profilePicture);
    final isLoading = authState.status == AuthStatus.loading;

    Widget avatar = const CircleAvatar(
      radius: 52,
      backgroundColor: MyTheme.primaryLight,
      child: Icon(Icons.person_rounded, size: 52, color: MyTheme.primary),
    );

    if (currentPhoto != null && currentPhoto.isNotEmpty) {
      if (currentPhoto.startsWith('http')) {
        avatar = CircleAvatar(
          radius: 52,
          backgroundImage: NetworkImage(currentPhoto),
          onBackgroundImageError: (_, _) {},
        );
      } else {
        final file = File(currentPhoto);
        if (file.existsSync()) {
          avatar = CircleAvatar(radius: 52, backgroundImage: FileImage(file));
        }
      }
    }

    return Scaffold(
      backgroundColor: MyTheme.background,
      appBar: AppBar(
        backgroundColor: MyTheme.surface,
        elevation: 0,
        title: Text(
          'Edit Profile',
          style: AppTypography.title(MyTheme.textPrimary),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: MyTheme.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pageAll,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: AppSpacing.cardPadding,
                decoration: AppDecorations.card(),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: MyTheme.primary, width: 2.5),
                      ),
                      child: avatar,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton.icon(
                      onPressed: isLoading ? null : _showSourceDialog,
                      icon: const Icon(Icons.upload_rounded, size: 18),
                      label: const Text('Change photo'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: AppSpacing.cardPadding,
                decoration: AppDecorations.card(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Account details',
                      style: AppTypography.titleSm(MyTheme.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _fullNameController,
                      style: AppTypography.body(MyTheme.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: MyTheme.textSecondary,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      initialValue: user?.email ?? '',
                      readOnly: true,
                      style: AppTypography.body(MyTheme.textSecondary),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        helperText: 'Email cannot be changed',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: MyTheme.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      initialValue: user?.role ?? 'User',
                      readOnly: true,
                      style: AppTypography.body(MyTheme.textSecondary),
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        prefixIcon: Icon(
                          Icons.badge_outlined,
                          color: MyTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: isLoading ? null : _saveProfile,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: MyTheme.textOnPrimary,
                        ),
                      )
                    : Text(
                        'Save changes',
                        style: AppTypography.button(MyTheme.textOnPrimary),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
