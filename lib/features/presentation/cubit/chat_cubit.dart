import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_state.dart';

/// Cubit for managing chat state
class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;

  ChatCubit(this._repository) : super(const ChatInitial()) {
    _initializeChat();
  }

  /// Initializes the chat with a welcome message
  Future<void> _initializeChat() async {
    try {
      final welcomeMessage = _repository.getWelcomeMessage();
      emit(ChatLoaded([welcomeMessage]));
    } catch (e) {
      emit(ChatError('Failed to initialize chat: ${e.toString()}', []));
    }
  }

  /// Sends a user message and gets a bot response
  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    final currentState = state;
    if (currentState is! ChatLoaded && currentState is! ChatLoading) return;

    try {
      // Get current messages list
      final currentMessages =
          currentState is ChatLoaded
              ? currentState.messages
              : (currentState as ChatLoading).messages;

      // Add user message immediately
      final userMsg = ChatMessage(
        id: _generateId(),
        text: userMessage.trim(),
        isUser: true,
        timestamp: DateTime.now(),
      );

      final updatedMessages = [...currentMessages, userMsg];
      emit(ChatLoaded(updatedMessages));

      // Emit loading state
      emit(ChatLoading(updatedMessages));

      // Get bot response
      final botResponse = await _repository.sendMessage(userMessage);
      final finalMessages = [...updatedMessages, botResponse];
      emit(ChatLoaded(finalMessages));
    } catch (e) {
      // On error, keep the messages (including user's message) and show error
      final currentMessages =
          currentState is ChatLoaded
              ? currentState.messages
              : (currentState as ChatLoading).messages;
      emit(
        ChatError('Failed to send message: ${e.toString()}', currentMessages),
      );
    }
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
