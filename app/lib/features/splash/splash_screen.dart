import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/routes.dart';
import 'splash_controller.dart';

/// Design tokens for the Legacy Notebook splash screen
class SplashTokens {
  static const bgTop       = Color(0xFF061E1C); // dark emerald vignette
  static const bgCenter    = Color(0xFF0A2E2B); // deep brand teal
  static const bgBottom    = Color(0xFF041413); // rich dark bottom
  static const gold        = Color(0xFFD4AF37); // metallic gold
  static const goldLight   = Color(0xFFF3E5AB); // champagne gold highlight
  static const goldSoft    = Color(0x66D4AF37); // 40% gold
  static const goldFaint   = Color(0x2BD4AF37); // ~17% gold
  static const wordmark    = Color(0xFFF5F5F7); // clean white
  static const wordmarkDim = Color(0xCCECEEF0); // 80% white
}

/// Fallback vector ledger icon if image asset is unavailable
class LedgerIcon extends StatelessWidget {
  const LedgerIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 92,
      decoration: BoxDecoration(
        color: const Color(0xFF0E3834),
        border: Border.all(color: SplashTokens.gold, width: 1.5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 10,
            top: 0,
            bottom: 0,
            child: Container(width: 1.5, color: SplashTokens.goldSoft),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 22, top: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 32, height: 1.5, color: SplashTokens.goldSoft),
                const SizedBox(height: 10),
                Container(width: 24, height: 1.5, color: SplashTokens.goldSoft),
                const SizedBox(height: 10),
                Container(width: 30, height: 1.5, color: SplashTokens.goldSoft),
              ],
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: Transform.rotate(
              angle: 0.785398, // 45 degrees
              child: Container(width: 6, height: 6, color: SplashTokens.gold),
            ),
          ),
        ],
      ),
    );
  }
}

/// Redesigned Editorial Splash Screen for Legacy Notebook
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoGlow;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _dividerScale;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _footerFade;

  @override
  void initState() {
    super.initState();

    // Edge-to-edge immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: SplashTokens.bgBottom,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    // Staggered 1400ms entrance animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    _logoScale = Tween<double>(begin: 0.78, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );

    _logoGlow = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.7, curve: Curves.easeInOut),
    );

    _titleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.28, 0.68, curve: Curves.easeOut),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.28, 0.68, curve: Curves.easeOutCubic),
      ),
    );

    _dividerScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.48, 0.82, curve: Curves.easeOutCubic),
    );

    _subtitleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 0.9, curve: Curves.easeOut),
    );

    _footerFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.68, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();

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

    final bodoni = GoogleFonts.bodoniModaTextTheme();
    final plusJakarta = GoogleFonts.plusJakartaSansTextTheme();
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: SplashTokens.bgCenter,
      body: Stack(
        children: [
          // Background Gradient Canvas
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.2),
                  radius: 1.2,
                  colors: [
                    SplashTokens.bgCenter,
                    SplashTokens.bgTop,
                    SplashTokens.bgBottom,
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // Ambient Glow Spot behind Logo
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final glow = disableAnimations ? 1.0 : _logoGlow.value;
                return Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    margin: const EdgeInsets.only(bottom: 120),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          SplashTokens.gold.withValues(alpha: 0.18 * glow),
                          const Color(0xFF0F5D6B).withValues(alpha: 0.22 * glow),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Main Content Area
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Semantics(
                label: 'Legacy Notebook — Field Credit Collection & Sales Management',
                container: true,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(flex: 3),

                      // Logo Icon with Ambient Glow & Shadow
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          final opacity = disableAnimations ? 1.0 : _logoFade.value;
                          final scale = disableAnimations ? 1.0 : _logoScale.value;
                          return Opacity(
                            opacity: opacity,
                            child: Transform.scale(
                              scale: scale,
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          width: 104,
                          height: 104,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.45),
                                blurRadius: 28,
                                offset: const Offset(0, 14),
                              ),
                              BoxShadow(
                                color: SplashTokens.gold.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              'assets/images/app_logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const LedgerIcon(),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Wordmark ("Legacy NOTEBOOK")
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          final opacity = disableAnimations ? 1.0 : _titleFade.value;
                          final slide = disableAnimations ? Offset.zero : _titleSlide.value;
                          return Opacity(
                            opacity: opacity,
                            child: SlideTransition(
                              position: AlwaysStoppedAnimation(slide),
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Text(
                              'Legacy',
                              style: bodoni.displayLarge!.copyWith(
                                fontSize: 44,
                                height: 1.05,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w300,
                                letterSpacing: -0.5,
                                color: SplashTokens.wordmark,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: Text(
                                'NOTEBOOK',
                                style: bodoni.displayLarge!.copyWith(
                                  fontSize: 34,
                                  height: 1.05,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 4.0,
                                  color: SplashTokens.gold,
                                  shadows: [
                                    Shadow(
                                      color: SplashTokens.gold.withValues(alpha: 0.35),
                                      blurRadius: 12,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Expanding Golden Divider Line
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) {
                          final scale = disableAnimations ? 1.0 : _dividerScale.value;
                          return SizedBox(
                            width: 80 * scale,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          SplashTokens.gold.withValues(alpha: 0.0),
                                          SplashTokens.goldSoft,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  width: 4,
                                  height: 4,
                                  transform: Matrix4.rotationZ(0.785398),
                                  decoration: const BoxDecoration(
                                    color: SplashTokens.gold,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          SplashTokens.goldSoft,
                                          SplashTokens.gold.withValues(alpha: 0.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 22),

                      // Tagline
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          final opacity = disableAnimations ? 1.0 : _subtitleFade.value;
                          return Opacity(
                            opacity: opacity,
                            child: child,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 1.8),
                          child: Text(
                            'FIELD CREDIT COLLECTION &\nSALES MANAGEMENT',
                            textAlign: TextAlign.center,
                            style: plusJakarta.labelMedium!.copyWith(
                              fontSize: 10.5,
                              height: 1.65,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.8,
                              color: SplashTokens.wordmarkDim,
                            ),
                          ),
                        ),
                      ),

                      const Spacer(flex: 4),

                      // Bottom Badge / Division
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          final opacity = disableAnimations ? 1.0 : _footerFade.value;
                          return Opacity(
                            opacity: opacity,
                            child: child,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F3A36).withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: SplashTokens.goldSoft.withValues(alpha: 0.35),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: SplashTokens.gold,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'HOME APPLIANCE DIVISION',
                                style: plusJakarta.labelSmall!.copyWith(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                  color: SplashTokens.goldLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
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
