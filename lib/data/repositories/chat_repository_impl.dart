import '../../core/constants/app_constants.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/dummy_chat_datasource.dart';

/// Implementation of ChatRepository using dummy data
class ChatRepositoryImpl implements ChatRepository {
  final DummyChatDatasource _datasource;

  ChatRepositoryImpl({DummyChatDatasource? datasource})
    : _datasource = datasource ?? DummyChatDatasource();

  @override
  Future<ChatMessage> sendMessage(String userMessage) async {
    // Simulate network delay
    await Future.delayed(
      Duration(milliseconds: AppConstants.botResponseDelayMs),
    );

    // Get intelligent response based on user message
    final response = _datasource.getResponse(userMessage);
    return ChatMessage(
      id: _generateId(),
      text: response,
      isUser: false,
      timestamp: DateTime.now(),
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
