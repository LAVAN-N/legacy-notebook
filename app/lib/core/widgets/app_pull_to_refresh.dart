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
    this.color,
    this.backgroundColor,
    this.triggerDistance = 65.0,
    this.holdDistance = 46.0,
  });

  final Widget child;
  final Future<void> Function() onRefresh;
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
  
  // Custom scroll controller to manage list offset and synchronize with gestures
  late final ScrollController _scrollController;

  double _pullDistance = 0.0;
  bool _isRefreshing = false;
  bool _isDragging = false;
  double? _dragStartY;
  bool _isAtTop = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
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
  void dispose() {
    _scrollController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (_isRefreshing) return;
    _dragStartY = event.position.dy;
    _isDragging = false;
    _isAtTop = !_scrollController.hasClients || _scrollController.offset <= 0.0;
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_isRefreshing || _dragStartY == null) return;
    
    final currentOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;

    if (_isAtTop && currentOffset <= 0.0) {
      final deltaY = event.position.dy - _dragStartY!;
      if (deltaY > 0) {
        _isDragging = true;
        const friction = 0.45;
        final newDist = deltaY * friction;
        setState(() {
          _pullDistance = newDist.clamp(0.0, 110.0);
        });
        
        // Keep the list scroll position locked at 0.0 while dragging down
        if (_scrollController.hasClients && _scrollController.offset != 0.0) {
          _scrollController.jumpTo(0.0);
        }
      } else if (_isDragging && deltaY <= 0) {
        setState(() {
          _pullDistance = 0.0;
        });
      } else if (_isDragging) {
        // Dragging back up but deltaY is still > 0
        const friction = 0.45;
        final newDist = deltaY * friction;
        setState(() {
          _pullDistance = newDist.clamp(0.0, 110.0);
        });
        
        // Keep scroll offset at 0.0 while the refresh icon is visible
        if (_pullDistance > 0.0 && _scrollController.hasClients && _scrollController.offset != 0.0) {
          _scrollController.jumpTo(0.0);
        }
      }
    } else {
      _dragStartY = event.position.dy;
      _isAtTop = currentOffset <= 0.0;
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _dragStartY = null;
    if (_isRefreshing) return;

    if (_isDragging && _pullDistance >= widget.triggerDistance) {
      _triggerRefresh();
    } else if (_pullDistance > 0.0) {
      _dismiss();
    }
    _isDragging = false;
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _dragStartY = null;
    if (!_isRefreshing && _pullDistance > 0.0) {
      _dismiss();
    }
    _isDragging = false;
  }

  void _triggerRefresh() async {
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final primaryColor = widget.color ?? colors.primary;
    final bgColor = widget.backgroundColor ?? colors.surface;

    final progress = (_pullDistance / widget.triggerDistance).clamp(0.0, 1.0);
    final isTriggerMet = _pullDistance >= widget.triggerDistance;

    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // Provide PrimaryScrollController so child lists attach to our controller
          PrimaryScrollController(
            controller: _scrollController,
            child: widget.child,
          ),

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
