import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';

/// State for the splash screen visibility
class SplashState {
  final bool isSplashVisible;

  const SplashState({required this.isSplashVisible});

  SplashState copyWith({bool? isSplashVisible}) {
    return SplashState(
      isSplashVisible: isSplashVisible ?? this.isSplashVisible,
    );
  }
}

/// Controller to manage splash screen visibility with timer triggered on mount
class SplashController extends StateNotifier<SplashState> {
  SplashController() : super(const SplashState(isSplashVisible: true));

  static const _minimumDuration = Duration(milliseconds: 3000); // 3.0s minimum display
  static const _maximumDuration = Duration(milliseconds: 4000); // 4.0s maximum safety limit

  bool _timerStarted = false;

  /// Start the splash display timer (called once the screen mounts)
  void startSplashTimer() {
    if (_timerStarted) return;
    _timerStarted = true;

    // Start the minimum timer
    Future.delayed(_minimumDuration, () {
      _dismissSplash();
    });

    // Safety timeout to ensure splash dismisses
    Future.delayed(_maximumDuration, () {
      _dismissSplash();
    });
  }

  /// Dismiss splash screen
  void _dismissSplash() {
    if (state.isSplashVisible) {
      state = state.copyWith(isSplashVisible: false);
    }
  }

  /// Force dismiss (e.g., for testing or early exit)
  void dismiss() {
    _dismissSplash();
  }
}

/// Riverpod provider for splash screen state
final splashControllerProvider = StateNotifierProvider<SplashController, SplashState>((ref) {
  return SplashController();
});
