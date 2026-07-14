import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Controller to manage splash screen visibility with timer and router idle tracking
class SplashController extends StateNotifier<SplashState> {
  SplashController() : super(const SplashState(isSplashVisible: true)) {
    _initSplash();
  }

  static const _minimumDuration = Duration(milliseconds: 900);
  static const _maximumDuration = Duration(milliseconds: 1800);

  bool _timerElapsed = false;
  bool _routerReady = false;

  /// Initialize splash: start timer and mark router as ready after initial build
  void _initSplash() {
    // Start the minimum timer
    Future.delayed(_minimumDuration, () {
      _timerElapsed = true;
      _checkDismiss();
    });

    // Mark router as ready after a brief delay to allow initial navigation setup
    Future.delayed(const Duration(milliseconds: 100), () {
      _routerReady = true;
      _checkDismiss();
    });

    // Safety timeout to ensure splash dismisses within maximum duration
    Future.delayed(_maximumDuration, () {
      _dismissSplash();
    });
  }

  /// Check if both conditions are met to dismiss splash
  void _checkDismiss() {
    if (_timerElapsed && _routerReady) {
      _dismissSplash();
    }
  }

  /// Dismiss splash screen
  void _dismissSplash() {
    state = state.copyWith(isSplashVisible: false);
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
