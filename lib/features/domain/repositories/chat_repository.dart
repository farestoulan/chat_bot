import '../../data/models/chat_message.dart';

abstract class ChatRepository {
  Future<void> sendMessageStream(
    String userMessage, {
    Map<String, dynamic>? userInfo,
    required Function(String token) onData,
    required Function() onDone,
    required Function(dynamic error) onError,
  });

  ChatMessage getWelcomeMessage();
}
