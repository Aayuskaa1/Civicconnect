import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:civic_connect/app/theme/my_theme.dart';
import 'package:civic_connect/app/theme/app_typography.dart';
import 'package:civic_connect/app/theme/app_spacing.dart';
import 'package:civic_connect/core/utils/snackbar_utils.dart';
import 'package:civic_connect/features/reports/presentation/state/report_state.dart';
import 'package:civic_connect/features/reports/presentation/view_model/report_view_model.dart';
import 'package:civic_connect/features/sensors/presentation/state/sensor_state.dart';

/// Filled by light/shake sensors before switching to the Submit tab.
final reportDraftProvider = StateProvider<ReportSuggestion?>((ref) => null);

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
    'Maintenance',
    'Water',
    'Electricity',
    'Safety',
    'Lighting',
    'Parking',
    'Noise',
    'Other',
  ];

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'maintenance':
        return Icons.handyman_outlined;
      case 'water':
        return Icons.water_drop_outlined;
      case 'electricity':
        return Icons.lightbulb_outline;
      case 'safety':
        return Icons.security_outlined;
      case 'lighting':
        return Icons.wb_twilight_outlined;
      case 'parking':
        return Icons.local_parking_outlined;
      case 'noise':
        return Icons.volume_up_outlined;
      default:
        return Icons.more_horiz;
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_applySensorDraft);
  }

  void _applySensorDraft() {
    final draft = ref.read(reportDraftProvider);
    if (draft == null) return;

    setState(() {
      if (draft.source == 'light') {
        _selectedCategory = 'Lighting';
      } else if (draft.category.isNotEmpty) {
        _selectedCategory = draft.category;
      }
      if (draft.title.isNotEmpty) {
        _titleController.text = draft.title;
      }
      if (draft.description.isNotEmpty) {
        _descriptionController.text = draft.description;
      }
    });
    ref.read(reportDraftProvider.notifier).state = null;
  }

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
        final sourceName =
            source == ImageSource.camera ? 'camera' : 'photo library';
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
                  'Add a photo',
                  style: AppTypography.titleSm(MyTheme.textPrimary),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'A clear photo helps management resolve the issue faster.',
                  style: AppTypography.bodySm(MyTheme.textSecondary),
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
                    'Choose from Gallery',
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
                    'Take a Photo',
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
                const SizedBox(height: AppSpacing.xs),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(reportViewModelProvider.notifier).submitReport(
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

    ref.listen<ReportSuggestion?>(reportDraftProvider, (previous, next) {
      if (next != null) {
        _applySensorDraft();
      }
    });

    ref.listen<ReportState>(reportViewModelProvider, (previous, next) {
      if (next.isSuccess && previous?.isSuccess != true) {
        SnackbarUtils.showSuccess(context, 'Issue submitted successfully!');
        ref.read(reportViewModelProvider.notifier).resetState();
        _titleController.clear();
        _descriptionController.clear();
        _locationController.clear();
        setState(() {
          _selectedCategory = null;
          _imagePath = null;
        });
      } else if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        SnackbarUtils.showError(context, next.errorMessage!);
        ref.read(reportViewModelProvider.notifier).resetState();
      }
    });

    return Scaffold(
      backgroundColor: MyTheme.background,
      appBar: AppBar(
        title: Text(
          'Submit Report',
          style: AppTypography.title(MyTheme.textPrimary),
        ),
        backgroundColor: MyTheme.surface,
        elevation: 0,
        centerTitle: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: AppSpacing.pageAll,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: AppSpacing.cardPadding,
                    decoration: AppDecorations.card(
                      color: MyTheme.primaryLight.withValues(alpha: 0.55),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: AppDecorations.iconWell(),
                          child: const Icon(
                            Icons.report_gmailerrorred_outlined,
                            color: MyTheme.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Report a building issue',
                                style: AppTypography.titleSm(
                                  MyTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                'Clear details help management respond quickly.',
                                style: AppTypography.bodySm(
                                  MyTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: AppSpacing.cardPadding,
                    decoration: AppDecorations.card(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Issue details',
                          style: AppTypography.titleSm(MyTheme.textPrimary),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _titleController,
                          style: AppTypography.body(MyTheme.textPrimary),
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            hintText: 'e.g. Leaking pipe in Block A',
                            prefixIcon: Icon(
                              Icons.title_rounded,
                              color: MyTheme.textSecondary,
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Please enter a title'
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          dropdownColor: MyTheme.surface,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            prefixIcon: Icon(
                              Icons.category_outlined,
                              color: MyTheme.textSecondary,
                            ),
                          ),
                          style: AppTypography.body(MyTheme.textPrimary),
                          selectedItemBuilder: (context) {
                            return _categories.map((cat) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  cat,
                                  style: AppTypography.body(
                                    MyTheme.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList();
                          },
                          items: _categories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat,
                              child: Row(
                                children: [
                                  Icon(
                                    _categoryIcon(cat),
                                    size: 18,
                                    color: MyTheme.primary,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Expanded(
                                    child: Text(
                                      cat,
                                      style: AppTypography.body(
                                        MyTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedCategory = val),
                          validator: (v) =>
                              v == null ? 'Please select a category' : null,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _locationController,
                          style: AppTypography.body(MyTheme.textPrimary),
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Location',
                            hintText: 'e.g. Block B, 3rd floor near lift',
                            prefixIcon: Icon(
                              Icons.location_on_outlined,
                              color: MyTheme.textSecondary,
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Please specify location'
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _descriptionController,
                          style: AppTypography.body(MyTheme.textPrimary),
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText:
                                'Describe the issue so it can be resolved quickly…',
                            alignLabelWithHint: true,
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Please enter a description'
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: AppSpacing.cardPadding,
                    decoration: AppDecorations.card(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Photo evidence',
                                style: AppTypography.titleSm(
                                  MyTheme.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              'Optional',
                              style: AppTypography.caption(
                                MyTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _showImageSourceDialog,
                            borderRadius:
                                BorderRadius.circular(MyTheme.radiusLg),
                            child: Ink(
                              height: 168,
                              decoration: BoxDecoration(
                                color: MyTheme.lightBg,
                                borderRadius:
                                    BorderRadius.circular(MyTheme.radiusLg),
                                border: Border.all(
                                  color: MyTheme.border,
                                  width: 1.5,
                                ),
                              ),
                              child: _imagePath == null
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(
                                            AppSpacing.sm,
                                          ),
                                          decoration: AppDecorations.iconWell(),
                                          child: const Icon(
                                            Icons.add_a_photo_outlined,
                                            color: MyTheme.primary,
                                            size: 28,
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.sm),
                                        Text(
                                          'Tap to add a photo',
                                          style: AppTypography.titleSm(
                                            MyTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.xxs),
                                        Text(
                                          'Camera or gallery',
                                          style: AppTypography.caption(
                                            MyTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            MyTheme.radiusLg,
                                          ),
                                          child: Image.file(
                                            File(_imagePath!),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: AppSpacing.xs,
                                          right: AppSpacing.xs,
                                          child: Material(
                                            color: MyTheme.surface,
                                            shape: const CircleBorder(),
                                            child: IconButton(
                                              tooltip: 'Remove photo',
                                              icon: const Icon(
                                                Icons.close_rounded,
                                                size: 18,
                                              ),
                                              onPressed: () => setState(
                                                () => _imagePath = null,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: AppSpacing.xs,
                                          bottom: AppSpacing.xs,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AppSpacing.xs,
                                              vertical: AppSpacing.xxs,
                                            ),
                                            decoration: BoxDecoration(
                                              color: MyTheme.surface.withValues(
                                                alpha: 0.92,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                MyTheme.radiusSm,
                                              ),
                                            ),
                                            child: Text(
                                              'Tap to change',
                                              style: AppTypography.caption(
                                                MyTheme.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ElevatedButton.icon(
                    onPressed: reportState.isLoading ? null : _submitReport,
                    icon: reportState.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: MyTheme.textOnPrimary,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 18),
                    label: Text(
                      reportState.isLoading ? 'Submitting…' : 'Submit Issue',
                      style: AppTypography.button(MyTheme.textOnPrimary),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Your report will appear as Pending until management updates it.',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption(MyTheme.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
          if (reportState.isLoading)
            Container(
              color: MyTheme.textPrimary.withValues(alpha: 0.18),
              child: const Center(
                child: CircularProgressIndicator(color: MyTheme.primary),
              ),
            ),
        ],
      ),
    );
  }
}
