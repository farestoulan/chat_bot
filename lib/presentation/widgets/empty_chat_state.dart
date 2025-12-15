import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/theme/app_theme.dart';

/// Widget displayed when there are no messages in the chat
class EmptyChatState extends StatelessWidget {
  const EmptyChatState({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final iconSize = isMobile ? 140.0 : 180.0;
    final iconInnerSize = isMobile ? 70.0 : 90.0;

    return Center(
      child: Padding(
        padding: ResponsiveHelper.getResponsivePadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(AppConstants.primaryColorValue).withOpacity(0.2),
                    const Color(AppConstants.secondaryColorValue).withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(AppConstants.primaryColorValue).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: iconInnerSize,
                color: const Color(AppConstants.primaryColorValue),
              ),
            ),
            SizedBox(height: isMobile ? 32 : 40),
            ShaderMask(
              shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
              child: Text(
                'Start a conversation',
                style: TextStyle(
                  fontSize: isMobile ? 26 : 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Type a message below to begin chatting',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                color: const Color(AppConstants.textColorDarkValue).withOpacity(0.6),
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(AppConstants.primaryColorValue).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'AI Powered',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
