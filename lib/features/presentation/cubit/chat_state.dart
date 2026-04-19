import '../../data/models/chat_message.dart';

abstract class ChatState {
  const ChatState();
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatUserInfoRequired extends ChatState {
  const ChatUserInfoRequired();
}

/// Lead API request in progress (after user taps Start Chat).
class ChatLeadCreating extends ChatState {
  const ChatLeadCreating();
}

/// Lead API failed; user stays on the form and can retry.
class ChatLeadCreationFailed extends ChatState {
  final String message;

  const ChatLeadCreationFailed(this.message);
}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;

  const ChatLoaded(this.messages);

  ChatLoaded copyWith({List<ChatMessage>? messages}) {
    return ChatLoaded(messages ?? this.messages);
  }
}

class ChatLoading extends ChatState {
  final List<ChatMessage> messages;

  const ChatLoading(this.messages);
}

/// Emitted on every new token while the bot response streams in.
/// [messages] includes all prior messages plus the in-progress bot message
/// whose text grows with each emission.
class ChatStreaming extends ChatState {
  final List<ChatMessage> messages;

  const ChatStreaming(this.messages);
}

class ChatError extends ChatState {
  final String message;
  final List<ChatMessage> messages;

  const ChatError(this.message, [this.messages = const []]);
}
