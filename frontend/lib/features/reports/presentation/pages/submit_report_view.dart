import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:civic_connect/app/theme/my_theme.dart';
import 'package:civic_connect/core/utils/snackbar_utils.dart';
import 'package:civic_connect/features/reports/presentation/state/report_state.dart';
import 'package:civic_connect/features/reports/presentation/view_model/report_view_model.dart';

class SubmitReportView extends ConsumerStatefulWidget {
  const SubmitReportView({super.key});

  @override
  ConsumerState<SubmitReportView> createState() => _SubmitReportViewState();
}

class _SubmitReportViewState extends ConsumerState<SubmitReportView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedCategory;
  String? _imagePath;

  bool get _isIosSimulator =>
      Platform.isIOS &&
      Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');

  final List<String> _categories = [
    'Road',
    'Water',
    'Electricity',
    'Safety',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
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
        final pickedFile = await picker.pickImage(
          source: source,
          imageQuality: 80,
        );
        if (pickedFile != null && mounted) {
          setState(() => _imagePath = pickedFile.path);
        }
      } else {
        if (mounted) {
          SnackbarUtils.showError(
            context,
            'Permission denied. Please enable permission in Settings.',
          );
        }
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

  void _showImageSourceDialog() {
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

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(reportViewModelProvider.notifier)
        .submitReport(
          _titleController.text.trim(),
          _descriptionController.text.trim(),
          _selectedCategory ?? 'Other',
          _locationController.text.trim(),
          _imagePath,
        );
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportViewModelProvider);

    ref.listen<ReportState>(reportViewModelProvider, (previous, next) {
      if (next.isSuccess) {
        SnackbarUtils.showSuccess(context, 'Issue submitted successfully!');
        ref.read(reportViewModelProvider.notifier).resetState();
        // Reset form inputs
        _titleController.clear();
        _descriptionController.clear();
        _locationController.clear();
        setState(() {
          _selectedCategory = null;
          _imagePath = null;
        });
      } else if (next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
        ref.read(reportViewModelProvider.notifier).resetState();
      }
    });

    return Stack(
      children: [
        Scaffold(
          backgroundColor: MyTheme.darkBackground,
          appBar: AppBar(
            title: const Text(
              'Submit Report',
              style: TextStyle(
                fontFamily: 'MontserratBold',
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: MyTheme.darkNavy,
            elevation: 0,
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Report a Community Issue',
                    style: TextStyle(
                      fontFamily: 'MontserratBold',
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Provide details about the problem. City officials and community members will see this issue.',
                    style: TextStyle(
                      fontFamily: 'MontserratRegular',
                      fontSize: 13,
                      color: Color(0xFF6B8FAF),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'MontserratRegular',
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Title / Issue Name',
                      hintText: 'e.g. Broken streetlight, pothole',
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Please enter a title'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    dropdownColor: MyTheme.darkNavy,
                    decoration: const InputDecoration(labelText: 'Category'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'MontserratRegular',
                    ),
                    items: _categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(
                          cat,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val),
                    validator: (v) =>
                        v == null ? 'Please select a category' : null,
                  ),
                  const SizedBox(height: 16),
                  // Location
                  TextFormField(
                    controller: _locationController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'MontserratRegular',
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Location / Landmark',
                      hintText: 'e.g. Main Street, near City Park',
                      prefixIcon: Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF6B8FAF),
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Please specify location'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'MontserratRegular',
                    ),
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Detailed Description',
                      hintText:
                          'Describe the issue so it can be resolved quickly...',
                      alignLabelWithHint: true,
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Please enter a description'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  // Image Picker Box
                  const Text(
                    'Attach Photo (Optional)',
                    style: TextStyle(
                      fontFamily: 'MontserratBold',
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: MyTheme.darkNavy,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF1E293B)),
                      ),
                      child: _imagePath == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_enhance_outlined,
                                  size: 40,
                                  color: Color(0xFF6B8FAF),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Tap to capture or upload photo',
                                  style: TextStyle(
                                    fontFamily: 'MontserratRegular',
                                    color: Color(0xFF6B8FAF),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(
                                File(_imagePath!),
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Submit Button
                  ElevatedButton(
                    onPressed: reportState.isLoading ? null : _submitReport,
                    child: reportState.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Submit Issue',
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
        ),
        // Loading Overlay
        if (reportState.isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: const Center(
              child: CircularProgressIndicator(color: MyTheme.civicBlue),
            ),
          ),
      ],
    );
  }
}
