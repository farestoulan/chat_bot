import '../../../core/constants/app_constants.dart';
import '../models/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/remote_chat_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final RemoteChatDatasource _datasource;

  ChatRepositoryImpl({required RemoteChatDatasource datasource})
    : _datasource = datasource;

  @override
  Future<void> sendMessageStream(
    String userMessage, {
    String? chatId,
    Map<String, dynamic>? userInfo,
    required Function(String token, String? chatId) onData,
    required Function() onDone,
    required Function(dynamic error) onError,
  }) {
    return _datasource.sendMessageStream(
      userMessage,
      chatId: chatId,
      userInfo: userInfo,
      onData: onData,
      onDone: onDone,
      onError: onError,
    );
  }

  @override
  ChatMessage getWelcomeMessage() {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: AppConstants.welcomeMessage,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }
}
