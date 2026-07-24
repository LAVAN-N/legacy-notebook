import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// A custom, high-fidelity loading animation featuring expanding concentric rings
/// (radar waves) pulsing outward from a central glowing collection bag/card core.
/// Used instead of generic spinning indicators to present a premium feel.
class PulseRippleLoader extends StatefulWidget {
  const PulseRippleLoader({
    super.key,
    this.size = 80,
    this.color,
    this.icon = Icons.sync,
  });

  final double size;
  final Color? color;
  final IconData icon;

  @override
  State<PulseRippleLoader> createState() => _PulseRippleLoaderState();
}

class _PulseRippleLoaderState extends State<PulseRippleLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final baseColor = widget.color ?? colors.primary;

    return SizedBox(
      width: widget.size * 2,
      height: widget.size * 2,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _PulseRipplePainter(
              progress: _controller.value,
              color: baseColor,
            ),
            child: Center(
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: baseColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: baseColor.withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 2 * math.pi),
                  duration: const Duration(seconds: 4),
                  builder: (context, value, child) {
                    return Transform.rotate(
                      angle: value,
                      child: Icon(
                        widget.icon,
                        color: colors.primaryFg,
                        size: widget.size * 0.45,
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PulseRipplePainter extends CustomPainter {
  _PulseRipplePainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2;

    // Draw three staggered expanding circles
    for (int i = 0; i < 3; i++) {
      final ringProgress = (progress + (i / 3.0)) % 1.0;
      final radius = maxRadius * ringProgress;
      final opacity = (1.0 - ringProgress).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = color.withValues(alpha: opacity * 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      canvas.drawCircle(center, radius, paint);

      final fillPaint = Paint()
        ..color = color.withValues(alpha: opacity * 0.04)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PulseRipplePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// A premium, custom horizontal dot wave animation where circular beads scale
/// and bounce in a staggered wave format to signal loading context.
class WaveDotLoader extends StatefulWidget {
  const WaveDotLoader({
    super.key,
    this.color,
    this.dotSize = 10,
    this.spacing = 6,
  });

  final Color? color;
  final double dotSize;
  final double spacing;

  @override
  State<WaveDotLoader> createState() => _WaveDotLoaderState();
}

class _WaveDotLoaderState extends State<WaveDotLoader>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();

    _startStaggeredLoop();
  }

  void _startStaggeredLoop() async {
    for (int i = 0; i < _controllers.length; i++) {
      if (!mounted) return;
      _controllers[i].repeat(reverse: true);
      await Future.delayed(const Duration(milliseconds: 180));
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dotColor = widget.color ?? colors.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            final value = _animations[index].value;
            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
              width: widget.dotSize,
              height: widget.dotSize,
              transform: Matrix4.translationValues(0.0, -value * 8.0, 0.0),
              decoration: BoxDecoration(
                color: dotColor.withValues(alpha: 0.4 + (value * 0.6)),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}

/// A full-screen translucent loading overlay widget that dims the behind context
/// and displays the [PulseRippleLoader] with a descriptive prompt status.
class CustomLoadingOverlay extends StatelessWidget {
  const CustomLoadingOverlay({
    super.key,
    required this.message,
    this.icon = Icons.sync,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Positioned.fill(
      child: Container(
        color: colors.background.withValues(alpha: 0.8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PulseRippleLoader(
                size: 64,
                icon: icon,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                message,
                style: AppTypography.titleMedium.copyWith(
                  color: colors.foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const WaveDotLoader(
                dotSize: 8,
                spacing: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
