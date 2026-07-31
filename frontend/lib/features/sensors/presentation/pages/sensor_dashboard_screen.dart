import 'package:civic_connect/app/theme/app_spacing.dart';
import 'package:civic_connect/app/theme/app_typography.dart';
import 'package:civic_connect/app/theme/my_theme.dart';
import 'package:civic_connect/features/dashboard/presentation/view_models/bottom_navigation_viewmodel.dart';
import 'package:civic_connect/features/sensors/presentation/pages/light_sensor_screen.dart';
import 'package:civic_connect/features/sensors/presentation/state/adaptive_brightness_state.dart';
import 'package:civic_connect/features/sensors/presentation/view_model/adaptive_brightness_controller.dart';
import 'package:civic_connect/features/sensors/presentation/view_model/sensor_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sensor dashboard — Adaptive Brightness (iOS system brightness) + motion demos.
class SensorDashboardScreen extends ConsumerWidget {
  const SensorDashboardScreen({super.key});

  static const routeName = '/sensor-dashboard';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensor = ref.watch(sensorControllerProvider);
    final controller = ref.read(sensorControllerProvider.notifier);
    final adaptive = ref.watch(adaptiveBrightnessProvider);
    final adaptiveController = ref.read(adaptiveBrightnessProvider.notifier);

    return Scaffold(
      backgroundColor: MyTheme.background,
      appBar: AppBar(
        backgroundColor: MyTheme.surface,
        title: Text(
          'Sensor Dashboard',
          style: AppTypography.title(MyTheme.textPrimary),
        ),
      ),
      body: ListView(
        padding: AppSpacing.pageAll,
        children: [
          Text(
            'Adaptive Brightness follows the system screen brightness '
            '(including OS auto-brightness). iOS does not expose ambient lux '
            'to apps — we only adapt CivicConnect’s UI.',
            style: AppTypography.body(MyTheme.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          _AdaptiveBrightnessCard(
            adaptive: adaptive,
            onChanged: adaptiveController.setEnabled,
          ),
          const SizedBox(height: AppSpacing.md),
          _SensorTile(
            icon: Icons.wb_sunny_outlined,
            title: 'Light Sensor',
            subtitle: sensor.lightAvailable
                ? (sensor.lux == null
                    ? 'Tap to view live lux reading'
                    : 'Current: ${sensor.lux!.toStringAsFixed(0)} lux')
                : 'Unavailable on this device (common on iOS)',
            onTap: () {
              Navigator.pushNamed(context, LightSensorScreen.routeName);
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          _SensorTile(
            icon: Icons.vibration,
            title: 'Accelerometer',
            subtitle: sensor.motionAvailable
                ? 'Shake to open Report · bump for Safety'
                : 'Unavailable on this device',
            onTap: sensor.motionAvailable
                ? () {
                    controller.simulateShake();
                    ref.read(bottomNavigationProvider.notifier).changeTab(2);
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }
                : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Simulator tests',
            style: AppTypography.titleSm(MyTheme.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          ElevatedButton.icon(
            onPressed: () => controller.simulateLowLight(),
            icon: const Icon(Icons.wb_twilight_outlined, size: 18),
            label: const Text('Test low light prompt'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () {
              controller.simulateShake();
              ref.read(bottomNavigationProvider.notifier).changeTab(2);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.vibration, size: 18),
            label: const Text('Test shake → Report'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => controller.simulateBump(),
            icon: const Icon(Icons.warning_amber_outlined, size: 18),
            label: const Text('Test hard bump'),
          ),
        ],
      ),
    );
  }
}

class _AdaptiveBrightnessCard extends StatelessWidget {
  const _AdaptiveBrightnessCard({
    required this.adaptive,
    required this.onChanged,
  });

  final AdaptiveBrightnessState adaptive;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final pct = (adaptive.systemBrightness * 100).round();

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: MyTheme.surface,
        borderRadius: BorderRadius.circular(MyTheme.radiusMd),
        border: Border.all(color: MyTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.brightness_auto_outlined,
                color: MyTheme.primary,
                size: 28,
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
                      !adaptive.available
                          ? 'Uses iOS system brightness (rebuild on device)'
                          : adaptive.enabled
                              ? 'System brightness $pct%'
                                  '${adaptive.isDarkUi ? ' · dark UI' : ' · light UI'}'
                              : 'Off — app theme stays light',
                      style: AppTypography.caption(MyTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: adaptive.enabled,
                onChanged: onChanged,
                activeTrackColor: MyTheme.primary,
              ),
            ],
          ),
          if (adaptive.available) ...[
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: adaptive.systemBrightness.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: MyTheme.border,
                color: MyTheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tip: drag brightness in Control Center — the bar and theme update live.',
              style: AppTypography.caption(MyTheme.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _SensorTile extends StatelessWidget {
  const _SensorTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MyTheme.surface,
      borderRadius: BorderRadius.circular(MyTheme.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MyTheme.radiusMd),
        child: Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MyTheme.radiusMd),
            border: Border.all(color: MyTheme.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: MyTheme.primary, size: 28),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleSm(MyTheme.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle,
                      style: AppTypography.caption(MyTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: MyTheme.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
