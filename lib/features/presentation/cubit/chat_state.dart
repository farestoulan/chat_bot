import '../../data/models/chat_message.dart';

/// Base state class for chat
abstract class ChatState {
  const ChatState();
}

/// Initial state when chat is loading
class ChatInitial extends ChatState {
  const ChatInitial();
}

/// State when chat is loaded with messages
class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;

  const ChatLoaded(this.messages);

  /// Creates a copy with updated messages
  ChatLoaded copyWith({List<ChatMessage>? messages}) {
    return ChatLoaded(messages ?? this.messages);
  }
}

/// State when a message is being sent/loaded
class ChatLoading extends ChatState {
  final List<ChatMessage> messages;

  const ChatLoading(this.messages);
}

/// State when an error occurs
class ChatError extends ChatState {
  final String message;
  final List<ChatMessage> messages;

  const ChatError(this.message, [this.messages = const []]);
}
