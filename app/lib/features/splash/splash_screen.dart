import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/routes.dart';
import 'splash_controller.dart';

/// Design tokens for the Legacy Notebook splash screen
class SplashTokens {
  static const bg = Color(0xFF0A2E2B); // deep solid brand teal (#0A2E2B)
}

/// Editorial Splash Screen rendering the approved design artwork
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    // Edge-to-edge immersive display
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: SplashTokens.bg,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    // Smooth calm 800ms fade-in
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    // Start splash screen display timer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(splashControllerProvider.notifier).startSplashTimer();
    });
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(splashControllerProvider, (previous, next) {
      if (!next.isSplashVisible) {
        context.go(Routes.dashboard);
      }
    });

    final disableAnimations = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: SplashTokens.bg,
      body: SizedBox.expand(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: disableAnimations ? 1.0 : _fade.value,
              child: child,
            );
          },
          child: Image.asset(
            'assets/images/splash_artwork.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) => Center(
              child: Image.asset(
                'assets/images/app_logo.png',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
