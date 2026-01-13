import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/theme/app_theme.dart';

/// Professional typing indicator widget that shows animated dots
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _animations =
        _controllers
            .map(
              (controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: controller, curve: Curves.easeInOut),
              ),
            )
            .toList();

    // Stagger the animations
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final avatarSize = ResponsiveHelper.getAvatarSize(context);
    final spacing = isMobile ? 10.0 : 14.0;
    final padding = ResponsiveHelper.getMessagePadding(context);
    final borderRadius = ResponsiveHelper.isMobile(context) ? 24.0 : 28.0;

    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 18 : 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Bot avatar
          Container(
            width: avatarSize,
            height: avatarSize,
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
              size: avatarSize * 0.6,
            ),
          ),
          SizedBox(width: spacing),
          // Typing bubble
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth:
                    ResponsiveHelper.isDesktop(context)
                        ? MediaQuery.of(context).size.width * 0.65
                        : double.infinity,
              ),
              child: Container(
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
                    color: const Color(
                      AppConstants.primaryColorValue,
                    ).withOpacity(0.2),
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    return AnimatedBuilder(
                      animation: _animations[index],
                      builder: (context, child) {
                        return Container(
                          margin: EdgeInsets.only(right: index < 2 ? 6.0 : 0),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(
                              AppConstants.textColorDarkValue,
                            ).withOpacity(
                              0.3 + (_animations[index].value * 0.5),
                            ),
                            shape: BoxShape.circle,
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
