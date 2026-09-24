import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// A sleek, customizable pull-to-refresh container where the child screen
/// content remains completely stationary/pinned, and only the floating refresh
/// badge pulls down and animates.
class AppPullToRefresh extends StatefulWidget {
  const AppPullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.enabled = true,
    this.color,
    this.backgroundColor,
    this.triggerDistance = 65.0,
    this.holdDistance = 46.0,
  });

  final Widget child;
  final Future<void> Function() onRefresh;
  final bool enabled;
  final Color? color;
  final Color? backgroundColor;
  final double triggerDistance;
  final double holdDistance;

  @override
  State<AppPullToRefresh> createState() => _AppPullToRefreshState();
}

class _AppPullToRefreshState extends State<AppPullToRefresh>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Animation<double>? _anim;

  double _pullDistance = 0.0;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(() {
        if (_anim != null) {
          setState(() {
            _pullDistance = _anim!.value;
          });
        }
      });
  }

  @override
  void didUpdateWidget(AppPullToRefresh oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && oldWidget.enabled) {
      if (_pullDistance > 0.0) {
        _dismiss();
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _triggerRefresh() async {
    if (_isRefreshing) return;
    HapticFeedback.lightImpact();
    _anim = Tween<double>(
      begin: _pullDistance,
      end: widget.holdDistance,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward(from: 0.0);

    setState(() {
      _isRefreshing = true;
    });

    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        _isRefreshing = false;
        _dismiss();
      }
    }
  }

  void _dismiss() {
    _anim = Tween<double>(begin: _pullDistance, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward(from: 0.0);
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (!widget.enabled || _isRefreshing) return false;

    if (notification is OverscrollNotification) {
      if (notification.overscroll < 0) {
        final delta = -notification.overscroll * 0.45;
        setState(() {
          _pullDistance = (_pullDistance + delta).clamp(0.0, 110.0);
        });
      }
    } else if (notification is ScrollUpdateNotification) {
      if (notification.metrics.extentBefore == 0 && (notification.scrollDelta ?? 0) < 0) {
        final delta = -(notification.scrollDelta ?? 0) * 0.45;
        setState(() {
          _pullDistance = (_pullDistance + delta).clamp(0.0, 110.0);
        });
      } else if (_pullDistance > 0 && (notification.scrollDelta ?? 0) > 0) {
        final delta = (notification.scrollDelta ?? 0) * 0.8;
        setState(() {
          _pullDistance = (_pullDistance - delta).clamp(0.0, 110.0);
        });
      }
    } else if (notification is ScrollEndNotification || notification is UserScrollNotification) {
      if (_pullDistance >= widget.triggerDistance) {
        _triggerRefresh();
      } else if (_pullDistance > 0 && !_animController.isAnimating) {
        _dismiss();
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final primaryColor = widget.color ?? colors.primary;
    final bgColor = widget.backgroundColor ?? colors.surface;

    final progress = (_pullDistance / widget.triggerDistance).clamp(0.0, 1.0);
    final isTriggerMet = _pullDistance >= widget.triggerDistance;

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          widget.child,

          // Pull-down Floating Refresh Badge
          if (_pullDistance > 0.0 || _isRefreshing)
            Positioned(
              top: _pullDistance - 38.0,
              child: Opacity(
                opacity: (_pullDistance / 24.0).clamp(0.0, 1.0),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(
                      color: colors.border.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: _isRefreshing
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                        )
                      : Transform.rotate(
                          angle: progress * 2 * math.pi,
                          child: Icon(
                            isTriggerMet
                                ? Icons.refresh_rounded
                                : Icons.arrow_downward_rounded,
                            color:
                                isTriggerMet ? primaryColor : colors.mutedFg,
                            size: 18,
                          ),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
