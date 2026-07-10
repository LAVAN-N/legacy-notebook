import 'package:flutter/material.dart';

/// Extension methods on BuildContext for convenient access to theme properties.
extension BuildContextExtensions on BuildContext {
  /// Get the current theme data.
  ThemeData get theme => Theme.of(this);

  /// Get the current color scheme.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Get the current text theme.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Get the current media query data.
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Get the device size.
  Size get size => mediaQuery.size;

  /// Get the device width.
  double get width => size.width;

  /// Get the device height.
  double get height => size.height;

  /// Check if the device is in portrait mode.
  bool get isPortrait => mediaQuery.orientation == Orientation.portrait;

  /// Check if the device is in landscape mode.
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;
}
