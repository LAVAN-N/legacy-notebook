import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/routes.dart';
import 'splash_controller.dart';

/// Design tokens for the Legacy Notebook splash screen
class SplashTokens {
  static const bg          = Color(0xFF0A2E2B); // deep teal
  static const gold        = Color(0xFFC5A02E); // primary accent
  static const goldSoft    = Color(0x66C5A02E); // 40% (dividers)
  static const goldFaint   = Color(0x33C5A02E); // 20%
  static const wordmark    = Color(0xFFE5E7EB); // near-white
  static const wordmarkDim = Color(0xCCE5E7EB); // 80%
}

/// A custom painted ledger book vector widget using nested container/stacks
class LedgerIcon extends StatelessWidget {
  const LedgerIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 96,
          decoration: BoxDecoration(
            border: Border.all(color: SplashTokens.gold, width: 1.5),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Stack(
            children: [
              // Bound line markers
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Container(width: 1, color: SplashTokens.goldSoft),
              ),
              Positioned(
                left: 12,
                top: 0,
                bottom: 0,
                child: Container(width: 1, color: SplashTokens.goldSoft),
              ),
              // Ledger lines
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 32, height: 1, color: SplashTokens.gold.withValues(alpha: .6)),
                    const SizedBox(height: 12),
                    Container(width: 24, height: 1, color: SplashTokens.gold.withValues(alpha: .6)),
                    const SizedBox(height: 12),
                    Container(width: 32, height: 1, color: SplashTokens.gold.withValues(alpha: .6)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Rotating diamond dot
        Transform.rotate(
          angle: 0.785398, // 45 degrees in radians
          child: Container(width: 4, height: 4, color: SplashTokens.gold),
        ),
      ],
    );
  }
}

/// Classic Editorial Splash Screen for Legacy Notebook (Centered Layout)
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<double> _rise;

  @override
  void initState() {
    super.initState();
    
    // Enable edge-to-edge mode so the app canvas renders behind system bars
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Style system overlay to draw transparent status bar with light (white) icons
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Seamless transparent background behind status bar
      statusBarIconBrightness: Brightness.light, // White status icons for dark background
      statusBarBrightness: Brightness.dark, // White status text for iOS
      systemNavigationBarColor: SplashTokens.bg, // Matches app background
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    // 900ms fade-in + translation transition
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _rise = Tween<double>(begin: 8.0, end: 0.0).animate(_fade);

    // Trigger splash dismissal timer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(splashControllerProvider.notifier).startSplashTimer();
    });
  }

  @override
  void dispose() {
    // Restore default transparent style and dark icons for the rest of the application
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // Default black icons for light theme
      statusBarBrightness: Brightness.light, // Default dark text for iOS
    ));
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(splashControllerProvider, (previous, next) {
      if (!next.isSplashVisible) {
        context.go(Routes.dashboard);
      }
    });

    final inter = GoogleFonts.interTextTheme();
    final bodoni = GoogleFonts.bodoniModaTextTheme();

    return Scaffold(
      backgroundColor: SplashTokens.bg,
      body: SafeArea(
        top: false, // Allow background to fill the status bar height area completely
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, child) {
            // Accessibility check: honor OS animation settings
            final disableAnimations = MediaQuery.of(context).disableAnimations;
            return Opacity(
              opacity: disableAnimations ? 1.0 : _fade.value,
              child: Transform.translate(
                offset: Offset(0, disableAnimations ? 0.0 : _rise.value),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: Semantics(
              label: 'Legacy Notebook — Credit Collection and Sales Management',
              container: true,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    
                    // Main Centered Content
                    Column(
                      children: [
                        const LedgerIcon(),
                        const SizedBox(height: 40),
                        Text(
                          'Legacy',
                          style: bodoni.displayLarge!.copyWith(
                            fontSize: 42,
                            height: 1.05,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w300,
                            letterSpacing: -0.5,
                            color: SplashTokens.wordmark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Compensate positive letterSpacing of 3.8 by adding 3.8 left padding for perfect alignment
                        Padding(
                          padding: const EdgeInsets.only(left: 3.8),
                          child: Text(
                            'NOTEBOOK',
                            style: bodoni.displayLarge!.copyWith(
                              fontSize: 38,
                              height: 1.05,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 3.8,
                              color: SplashTokens.gold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(width: 48, height: 1, color: SplashTokens.goldFaint),
                        const SizedBox(height: 24),
                        // Compensate positive letterSpacing of 1.65 with 1.65 left padding for perfect alignment
                        Padding(
                          padding: const EdgeInsets.only(left: 1.65),
                          child: Text(
                            'CREDIT COLLECTION &\nSALES MANAGEMENT',
                            textAlign: TextAlign.center,
                            style: inter.bodySmall!.copyWith(
                              fontSize: 11,
                              height: 1.6,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 1.65,
                              color: SplashTokens.wordmarkDim,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // Bottom block (footer)
                    // Compensate letterSpacing of 0.9 with 0.9 left padding for perfect alignment
                    Padding(
                      padding: const EdgeInsets.only(left: 0.9),
                      child: Text(
                        'HOME APPLIANCE DIVISION',
                        style: inter.bodySmall!.copyWith(
                          fontSize: 9,
                          letterSpacing: 0.9,
                          color: SplashTokens.gold.withValues(alpha: .5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
