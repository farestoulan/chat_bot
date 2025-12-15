/// Application-wide constants
class AppConstants {
  AppConstants._();

  // Colors - New Modern Design
  static const int primaryColorValue = 0xFF00D4AA; // Teal/Green
  static const int secondaryColorValue = 0xFF6C5CE7; // Purple
  static const int accentColorValue = 0xFFFF6B9D; // Pink
  static const int backgroundColorValue = 0xFF0F0F23; // Dark background
  static const int surfaceColorValue = 0xFF1A1A2E; // Dark surface
  static const int textColorDarkValue = 0xFFE0E0E0;
  static const int userMessageColorValue = 0xFF00D4AA;
  static const int botMessageColorValue = 0xFF1E1E3F;

  // Bot Configuration
  static const String botName = 'ChatBot Assistant';
  static const String botStatus = 'Online';
  static const String welcomeMessage =
      "Hello! 👋 I'm your friendly chatbot. How can I help you today?";

  // Timing
  static const int botResponseDelayMs = 800;
  static const int scrollAnimationDurationMs = 300;
  static const int scrollDelayMs = 100;

  // UI Dimensions
  static const double messageBubbleRadius = 20.0;
  static const double messageBubbleSmallRadius = 4.0;
  static const double avatarSize = 32.0;
  static const double appBarAvatarSize = 40.0;
  static const double sendButtonSize = 48.0;
  static const double inputBorderRadius = 24.0;
}

