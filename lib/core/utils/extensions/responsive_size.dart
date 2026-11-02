import 'dart:ui';

import 'package:flutter/cupertino.dart';

/// A point that defines how size should scale at a specific screen width.
class SizeBreakpoint {
  final double screenWidth; // Screen width (e.g. 320, 600, 1200)
  final double sizeMultiplier; // How much to scale the size at this width

  const SizeBreakpoint(this.screenWidth, this.sizeMultiplier);
}

/// List of screen sizes and how much we scale at each one.
/// The app will smoothly move between these values.
const List<SizeBreakpoint> _sizeBreakpoints = [
  SizeBreakpoint(320, 0.8), // Small phones
  SizeBreakpoint(375, 1.0), // Normal phones (base size)
  SizeBreakpoint(600, 1.2), // Large phones / small tablets
  SizeBreakpoint(900, 1.5), // Tablets
  SizeBreakpoint(1200, 1.8), // Small desktop
  SizeBreakpoint(1440, 2.2), // Large desktop
];

extension ResponsiveSize on BuildContext {
  /// Check if the device is in landscape mode
  bool get isLandScape =>
      MediaQuery.of(this).orientation == Orientation.landscape;

  /// Get screen width (fixed for landscape so layout stays consistent)
  double get screenWidth => isLandScape
      ? MediaQuery.of(this).size.height
      : MediaQuery.of(this).size.width;

  /// Get screen height (fixed for landscape)
  double get screenHeight => isLandScape
      ? MediaQuery.of(this).size.width
      : MediaQuery.of(this).size.height;

  /// Scale any size (like font or padding) based on screen width
  double setSize(double size) {
    final width = screenWidth;

    // Find nearest breakpoints above and below current width
    final upper = _sizeBreakpoints.firstWhere(
      (bp) => bp.screenWidth >= width,
      orElse: () => _sizeBreakpoints.last,
    );

    final lower = _sizeBreakpoints.lastWhere(
      (bp) => bp.screenWidth <= width,
      orElse: () => _sizeBreakpoints.first,
    );

    // If exact match or outside range, just use multiplier directly
    if (lower == upper) {
      return size * lower.sizeMultiplier;
    }

    // Calculate how far we are between lower and upper
    final lerpFactor =
        (width - lower.screenWidth) / (upper.screenWidth - lower.screenWidth);

    // Smoothly get a multiplier between the two breakpoints
    final interpolatedMultiplier = lerpDouble(
      lower.sizeMultiplier,
      upper.sizeMultiplier,
      lerpFactor,
    );

    // Return scaled size
    return size * (interpolatedMultiplier ?? lower.sizeMultiplier);
  }
}
