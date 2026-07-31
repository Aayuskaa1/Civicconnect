import 'package:civic_connect/app/theme/app_spacing.dart';
import 'package:civic_connect/app/theme/app_typography.dart';
import 'package:civic_connect/app/theme/my_theme.dart';
import 'package:civic_connect/features/sensors/presentation/view_model/adaptive_brightness_controller.dart';
import 'package:civic_connect/features/sensors/presentation/view_model/sensor_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Light / Adaptive Brightness screen.
///
/// On iOS, raw lux is usually unavailable. Adaptive Brightness uses system
/// screen brightness instead (see native [BrightnessMonitor]).
class LightSensorScreen extends ConsumerWidget {
  const LightSensorScreen({super.key});

  static const routeName = '/light-sensor';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensor = ref.watch(sensorControllerProvider);
    final controller = ref.read(sensorControllerProvider.notifier);
    final adaptive = ref.watch(adaptiveBrightnessProvider);
    final adaptiveController = ref.read(adaptiveBrightnessProvider.notifier);
    final lux = sensor.lux;
    final isDark =
        lux != null && lux < SensorController.lowLuxThreshold;
    final brightnessPct = (adaptive.systemBrightness * 100).round();

    return Scaffold(
      backgroundColor: MyTheme.background,
      appBar: AppBar(
        backgroundColor: MyTheme.surface,
        title: Text(
          'Light & Brightness',
          style: AppTypography.title(MyTheme.textPrimary),
        ),
      ),
      body: Padding(
        padding: AppSpacing.pageAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: MyTheme.surface,
                borderRadius: BorderRadius.circular(MyTheme.radiusLg),
                border: Border.all(color: MyTheme.border),
              ),
              child: Column(
                children: [
                  Icon(
                    adaptive.isDarkUi || isDark
                        ? Icons.wb_twilight_outlined
                        : Icons.wb_sunny_outlined,
                    size: 56,
                    color: (adaptive.isDarkUi || isDark)
                        ? MyTheme.statusPending
                        : MyTheme.primary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    adaptive.available
                        ? 'System brightness $brightnessPct%'
                        : (!sensor.lightAvailable
                            ? 'Light sensor unavailable on this device'
                            : (lux != null
                                ? '${lux.toStringAsFixed(1)} lux'
                                : 'Waiting for reading…')),
                    style: AppTypography.display(MyTheme.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    adaptive.available
                        ? 'Following UIScreen brightness (not lux)'
                        : (isDark
                            ? 'Low light — consider a Lighting report'
                            : 'Ambient brightness is OK'),
                    style: AppTypography.body(MyTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: MyTheme.surface,
                borderRadius: BorderRadius.circular(MyTheme.radiusMd),
                border: Border.all(color: MyTheme.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.brightness_auto_outlined,
                    color: MyTheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Adaptive Brightness',
                          style: AppTypography.titleSm(MyTheme.textPrimary),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          adaptive.enabled
                              ? 'On — theme & overlay follow system brightness'
                              : 'Off',
                          style: AppTypography.caption(MyTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: adaptive.enabled,
                    onChanged: adaptiveController.setEnabled,
                    activeTrackColor: MyTheme.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'iOS tip: change brightness in Control Center. CivicConnect adapts '
              'its theme/overlay — it never overrides system brightness.',
              style: AppTypography.bodySm(MyTheme.textSecondary),
            ),
            const Spacer(),
            if (isDark)
              ElevatedButton.icon(
                onPressed: () {
                  controller.simulateLowLight(lux: lux);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.report_outlined),
                label: const Text('Suggest Lighting report'),
              ),
          ],
        ),
      ),
    );
  }
}
