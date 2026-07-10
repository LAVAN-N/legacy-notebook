/// Material 3 Spacing Scale for consistent layouts.
/// All spacing values follow the 4dp base unit system.
class AppSpacing {
  // Base unit: 4dp
  static const double xs = 4.0; // Extra small
  static const double sm = 8.0; // Small
  static const double md = 12.0; // Medium
  static const double lg = 16.0; // Large
  static const double xl = 20.0; // Extra large
  static const double xxl = 24.0; // 2X Large

  // Derived spacing for specific components
  static const double screenPadding = lg; // 16dp horizontal padding on screens
  static const double sectionGap = md; // 12dp gap between sections
  static const double cardRadius = 16.0; // Card border radius
  static const double heroCardRadius = 20.0; // Hero card border radius
  static const double itemSpacing = sm; // 8dp gap between list items
  static const double chipSpacing = sm; // Gap between chips

  // Touch target sizing (Material 3 minimum: 48dp)
  static const double minTouchTarget = 48.0;
  static const double primaryButtonHeight = 56.0;
  static const double secondaryButtonHeight = 48.0;

  // App bar and bottom nav
  static const double appBarHeight = 64.0;
  static const double bottomNavHeight = 80.0;

  // Avatar sizing
  static const double avatarSmall = 32.0;
  static const double avatarMedium = 40.0;
  static const double avatarLarge = 56.0;
  static const double avatarHero = 96.0;

  // Icon sizing
  static const double iconSmall = 16.0;
  static const double iconDefault = 24.0;
  static const double iconLarge = 32.0;

  // Progress bar
  static const double progressBarHeight = 6.0;
  static const double thinProgressBarHeight = 2.0;
}
