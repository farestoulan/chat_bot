import 'package:flutter/material.dart';

/// Utility class for responsive design
class ResponsiveHelper {
  ResponsiveHelper._();

  /// Breakpoints for different screen sizes
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Check if current screen is desktop/web
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 20);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 24);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 28);
    }
  }

  /// Get responsive horizontal padding
  static double getHorizontalPadding(BuildContext context) {
    if (isMobile(context)) {
      return 16;
    } else if (isTablet(context)) {
      return 24;
    } else {
      return 32;
    }
  }

  /// Get responsive font size for messages
  static double getMessageFontSize(BuildContext context) {
    if (isMobile(context)) {
      return 15;
    } else if (isTablet(context)) {
      return 16;
    } else {
      return 17;
    }
  }

  /// Get responsive avatar size
  static double getAvatarSize(BuildContext context) {
    if (isMobile(context)) {
      return 32;
    } else if (isTablet(context)) {
      return 36;
    } else {
      return 40;
    }
  }

  /// Get responsive app bar avatar size
  static double getAppBarAvatarSize(BuildContext context) {
    if (isMobile(context)) {
      return 40;
    } else if (isTablet(context)) {
      return 44;
    } else {
      return 48;
    }
  }

  /// Get max width for chat container (for web/desktop)
  static double? getMaxChatWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 1200; // Max width for desktop
    } else if (isTablet(context)) {
      return 800; // Max width for tablet
    }
    return null; // Full width for mobile
  }

  /// Get responsive message bubble padding
  static EdgeInsets getMessagePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 18, vertical: 14);
    } else {
      return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
    }
  }

  /// Get responsive input field padding
  static EdgeInsets getInputPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    }
  }

  /// Get responsive border radius
  static double getBorderRadius(BuildContext context) {
    if (isMobile(context)) {
      return 24;
    } else {
      return 28;
    }
  }
}

