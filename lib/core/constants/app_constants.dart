/// Application-wide constants
class AppConstants {
  AppConstants._();

  // Odoo Lead API Configuration
  static const String odooBaseUrl =
      'https://singleclic-singleclic-odoo-staging1-27892597.dev.odoo.com';
  static const String odooApiKey =
      'Fqnhq706WsVOMKi0t5KCs7zY_gg2yGsUSjIsQJoDlOiNngBgrPTLkUZAN4bhg6kp';
  static const String leadEndpoint = '/api/v1/chatbot/lead';
  static const String defaultLeadText = "start chat";

  /// When empty, requests go directly to [odooBaseUrl] (mobile/desktop OK; web may hit CORS).
  /// For Flutter Web, point this at a **same-origin or CORS-enabled proxy** that forwards to Odoo:
  /// `flutter run -d chrome --dart-define=LEAD_API_BASE_URL=https://your-proxy.example.com`
  static const String _leadApiBaseUrlOverride = String.fromEnvironment(
    'LEAD_API_BASE_URL',
    defaultValue: '',
  );

  /// Optional path override when the proxy uses a different route than Odoo.
  static const String _leadApiPathOverride = String.fromEnvironment(
    'LEAD_API_PATH',
    defaultValue: '',
  );

  static String get leadApiEffectiveBaseUrl =>
      _leadApiBaseUrlOverride.isNotEmpty ? _leadApiBaseUrlOverride : odooBaseUrl;

  static String get leadApiEffectivePath =>
      _leadApiPathOverride.isNotEmpty ? _leadApiPathOverride : leadEndpoint;

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
      "Hello! 👋 I'm your friendly chatbot. How can I help you today? \n\n مرحباً! 👋 أنا روبوت الدردشة الودود الخاص بك. كيف يمكنني مساعدتك اليوم؟";

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
