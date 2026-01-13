import 'package:flutter/material.dart';
import '../../../core/utils/responsive_helper.dart';

/// Widget for displaying the SINGLECLIC logo as background
class BackgroundLogo extends StatelessWidget {
  final bool isEmptyState;

  const BackgroundLogo({super.key, this.isEmptyState = false});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Logo size based on screen size and state
    final logoSize =
        isEmptyState
            ? (isMobile ? screenWidth * 0.7 : screenWidth * 0.5)
            : (isMobile ? screenWidth * 0.8 : screenWidth * 0.6);

    // Opacity based on state - more visible when empty
    final opacity = isEmptyState ? 0.12 : 0.2;

    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: logoSize,
              height: logoSize,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }
}
