import '../../../core/constants/app_constants.dart';
import '../../../core/error_handling/exceptions.dart';
import '../models/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/remote_chat_datasource.dart';

/// Implementation of ChatRepository using remote API
class ChatRepositoryImpl implements ChatRepository {
  final RemoteChatDatasource _datasource;

  ChatRepositoryImpl({required RemoteChatDatasource datasource})
    : _datasource = datasource;

  @override
  Future<ChatMessage> sendMessage(String userMessage) async {
    final result = await _datasource.sendMessage(userMessage);

    return result.fold(
      (error) {
        throw NetworkException(
          message: error.message,
          statusCode: error.statusCode,
        );
      },
      (content) {
        return ChatMessage(
          id: _generateId(),
          text: content,
          isUser: false,
          timestamp: DateTime.now(),
        );
      },
    );
  }

  @override
  ChatMessage getWelcomeMessage() {
    return ChatMessage(
      id: _generateId(),
      text: AppConstants.welcomeMessage,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
