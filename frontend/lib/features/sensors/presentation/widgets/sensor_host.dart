import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/app/theme/my_theme.dart';
import 'package:civic_connect/app/theme/app_typography.dart';
import 'package:civic_connect/app/theme/app_spacing.dart';
import 'package:civic_connect/features/dashboard/presentation/view_models/bottom_navigation_viewmodel.dart';
import 'package:civic_connect/features/reports/presentation/pages/submit_report_view.dart';
import 'package:civic_connect/features/sensors/presentation/state/sensor_state.dart';
import 'package:civic_connect/features/sensors/presentation/view_model/sensor_controller.dart';

/// Starts light + accelerometer sensors while the dashboard is open.
class SensorHost extends ConsumerStatefulWidget {
  const SensorHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SensorHost> createState() => _SensorHostState();
}

class _SensorHostState extends ConsumerState<SensorHost> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(sensorControllerProvider.notifier).start());
  }

  Future<void> _handleSuggestion(ReportSuggestion suggestion) async {
    final notifier = ref.read(sensorControllerProvider.notifier);

    if (suggestion.source == 'shake') {
      notifier.clearSuggestion();
      ref.read(bottomNavigationProvider.notifier).changeTab(2);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Shake detected — Report an issue',
              style: AppTypography.body(MyTheme.textOnPrimary),
            ),
            backgroundColor: MyTheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final shouldReport = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isLight = suggestion.source == 'light';
        return AlertDialog(
          backgroundColor: MyTheme.surface,
          title: Text(
            isLight ? 'Low light detected' : 'Hard bump detected',
            style: AppTypography.title(MyTheme.textPrimary),
          ),
          content: Text(
            isLight
                ? 'This area looks poorly lit (dark hallway / stairwell). '
                    'Would you like to file a Safety / Lighting report?'
                : 'A strong jolt was detected. Report a safety concern?',
            style: AppTypography.body(MyTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Not now',
                style: AppTypography.caption(MyTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Report issue'),
            ),
          ],
        );
      },
    );

    notifier.clearSuggestion();
    if (shouldReport != true || !mounted) return;

    ref.read(reportDraftProvider.notifier).state = suggestion;
    ref.read(bottomNavigationProvider.notifier).changeTab(2);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SensorState>(sensorControllerProvider, (previous, next) {
      final suggestion = next.pendingSuggestion;
      if (suggestion == null) return;
      // Fire on every new sensor event (simulator buttons can repeat).
      if (previous?.eventId == next.eventId) return;
      _handleSuggestion(suggestion);
    });

    return widget.child;
  }
}

/// Opens the sensor demo / status sheet (Profile → Sensors & gestures).
void showSensorCheckSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: MyTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(MyTheme.radiusLg),
      ),
    ),
    builder: (context) => const _SensorCheckSheet(),
  );
}

class _SensorCheckSheet extends ConsumerWidget {
  const _SensorCheckSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensor = ref.watch(sensorControllerProvider);
    final controller = ref.read(sensorControllerProvider.notifier);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
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
              'Sensor check',
              style: AppTypography.title(MyTheme.textPrimary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Use these on simulator. On a real phone, cover the light '
              'sensor or shake the device.',
              style: AppTypography.bodySm(MyTheme.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            _StatusRow(
              label: 'Light sensor',
              value: sensor.lux == null
                  ? (sensor.lightAvailable ? 'Waiting…' : 'Unavailable here')
                  : '${sensor.lux!.toStringAsFixed(1)} lux'
                      '${sensor.isDarkArea ? ' (dark)' : ''}',
            ),
            _StatusRow(
              label: 'Accelerometer',
              value: sensor.motionAvailable ? 'Listening' : 'Unavailable',
            ),
            _StatusRow(
              label: 'Ambient theme',
              value: sensor.ambientThemeMode ?? 'system',
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Future.microtask(controller.simulateLowLight);
              },
              icon: const Icon(Icons.wb_twilight_outlined, size: 18),
              label: const Text('Test low light'),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Future.microtask(controller.simulateShake);
              },
              icon: const Icon(Icons.vibration, size: 18),
              label: const Text('Test shake → Report'),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Future.microtask(controller.simulateBump);
              },
              icon: const Icon(Icons.warning_amber_outlined, size: 18),
              label: const Text('Test hard bump'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodySm(MyTheme.textSecondary),
            ),
          ),
          Text(
            value,
            style: AppTypography.titleSm(MyTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}
