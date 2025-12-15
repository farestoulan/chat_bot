import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/theme/app_theme.dart';

/// Custom app bar for the chat screen
class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final avatarSize = ResponsiveHelper.getAppBarAvatarSize(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final maxWidth = ResponsiveHelper.getMaxChatWidth(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(AppConstants.backgroundColorValue),
            const Color(AppConstants.surfaceColorValue).withOpacity(0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          bottom: BorderSide(
            color: const Color(AppConstants.primaryColorValue).withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth ?? double.infinity,
            ),
            child: Row(
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(AppConstants.secondaryColorValue)
                            .withOpacity(0.5),
                        blurRadius: 15,
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
                SizedBox(width: isMobile ? 14 : 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppConstants.botName,
                      style: TextStyle(
                        color: const Color(AppConstants.textColorDarkValue),
                        fontSize: isMobile ? 19 : 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(AppConstants.primaryColorValue),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(AppConstants.primaryColorValue)
                                    .withOpacity(0.6),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          AppConstants.botStatus,
                          style: TextStyle(
                            color: const Color(AppConstants.textColorDarkValue)
                                .withOpacity(0.7),
                            fontSize: isMobile ? 12 : 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(AppConstants.surfaceColorValue),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(AppConstants.primaryColorValue).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.more_vert_rounded,
                color: const Color(AppConstants.textColorDarkValue),
                size: isMobile ? 22 : 24,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
