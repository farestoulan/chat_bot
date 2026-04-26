import '../../data/models/chat_message.dart';

abstract class ChatRepository {
  Future<void> sendMessageStream(
    String userMessage, {
    String? chatId,
    Map<String, dynamic>? userInfo,
    required Function(String token, String? chatId) onData,
    required Function() onDone,
    required Function(dynamic error) onError,
  });

  ChatMessage getWelcomeMessage();
}
