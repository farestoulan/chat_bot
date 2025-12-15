import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/empty_chat_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input_field.dart';
import '../widgets/background_logo.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive_helper.dart';

/// Main chat screen widget
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(ChatCubit cubit) {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text;
    _messageController.clear();
    cubit.sendMessage(message);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: AppConstants.scrollDelayMs), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(
            milliseconds: AppConstants.scrollAnimationDurationMs,
          ),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildResponsiveChatContent(ChatLoaded state) {
    final isEmpty = state.messages.isEmpty;

    return Stack(
      children: [
        // Background logo - more visible when empty, subtle when has messages
        BackgroundLogo(isEmptyState: isEmpty),
        // Chat content
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth:
                  ResponsiveHelper.getMaxChatWidth(context) ?? double.infinity,
            ),
            child: Column(
              children: [
                Expanded(
                  child:
                      isEmpty
                          ? const EmptyChatState()
                          : ListView.builder(
                            controller: _scrollController,
                            padding: ResponsiveHelper.getResponsivePadding(
                              context,
                            ),
                            itemCount: state.messages.length,
                            itemBuilder: (context, index) {
                              return MessageBubble(
                                message: state.messages[index],
                              );
                            },
                          ),
                ),
                MessageInputField(
                  controller: _messageController,
                  onSend: () => _sendMessage(context.read<ChatCubit>()),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundColorValue),
      appBar: const ChatAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(AppConstants.backgroundColorValue),
              const Color(AppConstants.surfaceColorValue).withOpacity(0.3),
            ],
          ),
        ),
        child: BlocConsumer<ChatCubit, ChatState>(
          listener: (context, state) {
            if (state is ChatLoaded) {
              _scrollToBottom();
            }
          },
          builder: (context, state) {
            if (state is ChatInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ChatError) {
              return Center(
                child: Padding(
                  padding: ResponsiveHelper.getResponsivePadding(context),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: ResponsiveHelper.isMobile(context) ? 64 : 80,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize:
                              ResponsiveHelper.isMobile(context) ? 14 : 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is ChatLoaded) {
              return _buildResponsiveChatContent(state);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
