import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/chat_message.dart';

/// Widget for displaying a chat message bubble
class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final avatarSize = ResponsiveHelper.getAvatarSize(context);
    final spacing = isMobile ? 10.0 : 14.0;

    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 18 : 22),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            _buildBotAvatar(context, avatarSize),
            SizedBox(width: spacing),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth:
                    ResponsiveHelper.isDesktop(context)
                        ? MediaQuery.of(context).size.width * 0.65
                        : double.infinity,
              ),
              child: _buildBubble(context),
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: spacing),
            _buildUserAvatar(context, avatarSize),
          ],
        ],
      ),
    );
  }

  Widget _buildBubble(BuildContext context) {
    final padding = ResponsiveHelper.getMessagePadding(context);
    final fontSize = ResponsiveHelper.getMessageFontSize(context);
    final borderRadius = ResponsiveHelper.isMobile(context) ? 24.0 : 28.0;

    if (message.isUser) {
      // User message with gradient
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(borderRadius),
            topRight: Radius.circular(borderRadius),
            bottomLeft: Radius.circular(borderRadius),
            bottomRight: const Radius.circular(8),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                AppConstants.primaryColorValue,
              ).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormatter.formatTime(message.timestamp),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: ResponsiveHelper.isMobile(context) ? 10 : 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // Bot message with glassmorphism effect
      final theme = Theme.of(context);

      return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: const Color(AppConstants.botMessageColorValue),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(borderRadius),
            topRight: Radius.circular(borderRadius),
            bottomLeft: const Radius.circular(8),
            bottomRight: Radius.circular(borderRadius),
          ),
          border: Border.all(
            color: const Color(AppConstants.primaryColorValue).withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: const Color(AppConstants.textColorDarkValue),
                fontSize: fontSize,
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              DateFormatter.formatTime(message.timestamp),
              style: TextStyle(
                color: const Color(
                  AppConstants.textColorDarkValue,
                ).withOpacity(0.6),
                fontSize: ResponsiveHelper.isMobile(context) ? 10 : 11,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildBotAvatar(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppTheme.accentGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(
              AppConstants.secondaryColorValue,
            ).withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        Icons.smart_toy_rounded,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(AppConstants.primaryColorValue).withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(Icons.person_rounded, color: Colors.white, size: size * 0.6),
    );
  }
}
