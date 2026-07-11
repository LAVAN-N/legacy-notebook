import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';

// Simple StateNotifier for mock sync status
class SyncStateNotifier extends StateNotifier<SyncState> {
  SyncStateNotifier() : super(const SyncState(status: SyncStatus.synced, pendingCount: 0)) {
    // Periodically change state to simulate sync activity for UI/demo purposes
    _startDemoLoop();
  }

  void _startDemoLoop() async {
    while (true) {
      await Future.delayed(const Duration(seconds: 15));
      if (mounted) {
        state = const SyncState(status: SyncStatus.syncing, pendingCount: 3);
      }
      await Future.delayed(const Duration(seconds: 4));
      if (mounted) {
        state = const SyncState(status: SyncStatus.synced, pendingCount: 0);
      }
    }
  }

  void incrementPending() {
    state = SyncState(
      status: SyncStatus.offline,
      pendingCount: state.pendingCount + 1,
    );
    // Auto-resolve sync in 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        state = const SyncState(status: SyncStatus.synced, pendingCount: 0);
      }
    });
  }
}

enum SyncStatus { synced, offline, syncing }

class SyncState {
  const SyncState({required this.status, required this.pendingCount});
  final SyncStatus status;
  final int pendingCount;
}

final syncProvider = StateNotifierProvider<SyncStateNotifier, SyncState>((ref) {
  return SyncStateNotifier();
});

class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);
    final colors = context.colors;

    IconData icon;
    Color color;
    String tooltip;

    switch (syncState.status) {
      case SyncStatus.synced:
        icon = Icons.cloud_done; // Material equivalent
        color = colors.success;
        tooltip = 'All activities synced';
        break;
      case SyncStatus.offline:
        icon = Icons.cloud_off;
        color = colors.warning;
        tooltip = '${syncState.pendingCount} activities pending sync';
        break;
      case SyncStatus.syncing:
        icon = Icons.refresh;
        color = colors.primary;
        tooltip = 'Syncing...';
        break;
    }

    final widget = Tooltip(
      message: tooltip,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: syncState.status == SyncStatus.syncing
            ? RotationTransitionWidget(
                child: Icon(icon, color: color, size: 20),
              )
            : Icon(icon, color: color, size: 20, key: ValueKey(syncState.status)),
      ),
    );

    if (syncState.status == SyncStatus.offline && syncState.pendingCount > 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colors.warning.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              '${syncState.pendingCount} Pending',
              style: AppTypography.labelSmall.copyWith(color: colors.warning),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          widget,
        ],
      );
    }

    return widget;
  }
}

class RotationTransitionWidget extends StatefulWidget {
  const RotationTransitionWidget({super.key, required this.child});
  final Widget child;

  @override
  State<RotationTransitionWidget> createState() => _RotationTransitionWidgetState();
}

class _RotationTransitionWidgetState extends State<RotationTransitionWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: widget.child,
    );
  }
}
