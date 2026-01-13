import '../../data/models/chat_message.dart';

/// Repository interface for chat operations
/// This follows the dependency inversion principle
abstract class ChatRepository {
  /// Sends a user message and returns a bot response
  Future<ChatMessage> sendMessage(String userMessage);

  /// Gets the welcome message from the bot
  ChatMessage getWelcomeMessage();
}
