import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/utils/text_direction_helper.dart';
import '../../../core/theme/app_theme.dart';
import '../../data/models/chat_message.dart';

/// Widget for displaying a chat message bubble
class MessageBubble extends StatefulWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _isHovered = false;
  bool _copied = false;

  /// Parses Markdown-like text: **bold**, *bold*, and [text](url) into [TextSpan]s.
  List<InlineSpan> _parseMarkdownSpans(
    String text,
    TextStyle baseStyle,
    TextStyle boldStyle,
    TextStyle linkStyle,
  ) {
    final spans = <InlineSpan>[];
    final boldDouble = RegExp(r'\*\*([^*]+)\*\*');
    final boldSingle = RegExp(r'\*([^*]+)\*');
    final link = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');
    int pos = 0;

    while (pos < text.length) {
      int? nextStart;
      int nextEnd = pos;
      String? boldText;
      String? linkText;
      String? linkUrl;

      final boldDoubleMatch = boldDouble.firstMatch(text.substring(pos));
      if (boldDoubleMatch != null) {
        nextStart = pos + boldDoubleMatch.start;
        nextEnd = pos + boldDoubleMatch.end;
        boldText = boldDoubleMatch.group(1);
      }

      final boldSingleMatch = boldSingle.firstMatch(text.substring(pos));
      if (boldSingleMatch != null) {
        final start = pos + boldSingleMatch.start;
        if (nextStart == null || start < nextStart) {
          nextStart = start;
          nextEnd = pos + boldSingleMatch.end;
          boldText = boldSingleMatch.group(1);
        }
      }

      final linkMatch = link.firstMatch(text.substring(pos));
      if (linkMatch != null) {
        final start = pos + linkMatch.start;
        if (nextStart == null || start < nextStart) {
          nextStart = start;
          nextEnd = pos + linkMatch.end;
          boldText = null;
          linkText = linkMatch.group(1);
          linkUrl = linkMatch.group(2);
        }
      }

      if (nextStart == null) {
        spans.add(TextSpan(text: text.substring(pos), style: baseStyle));
        break;
      }

      if (nextStart > pos) {
        spans.add(TextSpan(
          text: text.substring(pos, nextStart),
          style: baseStyle,
        ));
      }

      if (boldText != null) {
        spans.add(TextSpan(text: boldText, style: boldStyle));
      } else if (linkText != null && linkUrl != null) {
        final url = linkUrl.trim();
        spans.add(TextSpan(
          text: linkText,
          style: linkStyle,
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              final uri = Uri.tryParse(url.startsWith('http') ? url : 'https://$url');
              if (uri != null && await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
        ));
      }

      pos = nextEnd;
    }

    if (spans.isEmpty) {
      spans.add(TextSpan(text: text, style: baseStyle));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final avatarSize = ResponsiveHelper.getAvatarSize(context);
    final spacing = isMobile ? 10.0 : 14.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Padding(
        padding: EdgeInsets.only(bottom: isMobile ? 18 : 22),
        child: Row(
          mainAxisAlignment:
              widget.message.isUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!widget.message.isUser) ...[
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
            if (widget.message.isUser) ...[
              SizedBox(width: spacing),
              _buildUserAvatar(context, avatarSize),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(BuildContext context) {
    final padding = ResponsiveHelper.getMessagePadding(context);
    final fontSize = ResponsiveHelper.getMessageFontSize(context);
    final borderRadius = ResponsiveHelper.isMobile(context) ? 24.0 : 28.0;
    final isArabic = TextDirectionHelper.isArabic(widget.message.text);

    if (widget.message.isUser) {
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
          crossAxisAlignment:
              isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            SelectableText.rich(
              TextSpan(
                children: _parseMarkdownSpans(
                  widget.message.text,
                  TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                  TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    height: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                  TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
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
                  DateFormatter.formatTime(widget.message.timestamp),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: ResponsiveHelper.isMobile(context) ? 10 : 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (_isHovered) ...[
                  const SizedBox(width: 8),
                  _buildCopyButton(
                    context,
                    iconColor: Colors.white.withOpacity(0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    } else {
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
          crossAxisAlignment:
              isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            SelectableText.rich(
              TextSpan(
                children: _parseMarkdownSpans(
                  widget.message.text,
                  TextStyle(
                    color: const Color(AppConstants.textColorDarkValue),
                    fontSize: fontSize,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                  TextStyle(
                    color: const Color(AppConstants.textColorDarkValue),
                    fontSize: fontSize,
                    height: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                  TextStyle(
                    color: const Color(AppConstants.primaryColorValue),
                    fontSize: fontSize,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormatter.formatTime(widget.message.timestamp),
                  style: TextStyle(
                    color: const Color(
                      AppConstants.textColorDarkValue,
                    ).withOpacity(0.6),
                    fontSize: ResponsiveHelper.isMobile(context) ? 10 : 11,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                if (_isHovered) ...[
                  const SizedBox(width: 8),
                  _buildCopyButton(
                    context,
                    iconColor: const Color(
                      AppConstants.textColorDarkValue,
                    ).withOpacity(0.5),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildCopyButton(BuildContext context, {required Color iconColor}) {
    return Tooltip(
      message: _copied ? 'Copied!' : 'Copy',
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: widget.message.text));
          setState(() => _copied = true);
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) setState(() => _copied = false);
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(
            _copied ? Icons.check_rounded : Icons.copy_rounded,
            size: 14,
            color: iconColor,
          ),
        ),
      ),
    );
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
