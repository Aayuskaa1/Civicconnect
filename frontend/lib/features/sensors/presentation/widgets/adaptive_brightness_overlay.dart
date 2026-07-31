import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/features/sensors/presentation/view_model/adaptive_brightness_controller.dart';

/// Subtle dimming veil that tracks system brightness when Adaptive Brightness
/// is on. Does not change `UIScreen` brightness — in-app UI only.
class AdaptiveBrightnessOverlay extends ConsumerWidget {
  const AdaptiveBrightnessOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adaptive = ref.watch(adaptiveBrightnessProvider);

    if (!adaptive.enabled || !adaptive.available) {
      return child;
    }

    // Darker system brightness → slightly stronger in-app veil (max ~18%).
    final veil = ((1.0 - adaptive.systemBrightness) * 0.18).clamp(0.0, 0.18);

    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (veil > 0.02)
          IgnorePointer(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              color: Colors.black.withValues(alpha: veil),
            ),
          ),
      ],
    );
  }
}
