import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/theme/app_theme.dart';

/// Widget for the message input field at the bottom of the chat
class MessageInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const MessageInputField({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.getInputPadding(context);
    final maxWidth = ResponsiveHelper.getMaxChatWidth(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final theme = Theme.of(context);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
            child: Row(
              children: [
                Expanded(child: _buildTextField(context)),
                SizedBox(width: isMobile ? 12 : 16),
                _buildSendButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context) {
    final borderRadius = ResponsiveHelper.getBorderRadius(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: theme.colorScheme.onBackground,
          fontSize: isMobile ? 15 : 16,
        ),
        decoration: InputDecoration(
          hintText: 'Type a message...',
          hintStyle: TextStyle(
            color: theme.colorScheme.onBackground.withOpacity(0.4),
            fontSize: isMobile ? 15 : 16,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 22 : 26,
            vertical: isMobile ? 14 : 16,
          ),
        ),
        maxLines: null,
        textInputAction: TextInputAction.send,
        onSubmitted: (_) => onSend(),
      ),
    );
  }

  Widget _buildSendButton(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final buttonSize =
        isMobile
            ? AppConstants.sendButtonSize
            : AppConstants.sendButtonSize + 4;

    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(AppConstants.primaryColorValue).withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(buttonSize / 2),
          onTap: onSend,
          child: Icon(
            Icons.send_rounded,
            color: Colors.white,
            size: isMobile ? 20 : 22,
          ),
        ),
      ),
    );
  }
}
