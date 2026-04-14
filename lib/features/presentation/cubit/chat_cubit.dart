import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/web.dart' as web;
import '../../data/models/chat_message.dart';
import '../../data/models/user_info.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;

  /// Delay between displaying each word.
  static const _wordDelay = Duration(milliseconds: 40);

  static const _keyUserName = 'chatbot_user_name';
  static const _keyUserContact = 'chatbot_user_contact';
  static const _keyMessages = 'chatbot_messages';
  static const _maxStoredMessages = 25;

  final _wordQueue = <String>[];
  bool _isProcessing = false;
  bool _isCancelled = false;

  UserInfo? _userInfo;
  UserInfo? get userInfo => _userInfo;

  ChatCubit(this._repository) : super(const ChatUserInfoRequired()) {
    _loadSavedSession();
  }

  void _loadSavedSession() {
    try {
      final storage = web.window.sessionStorage;
      final savedName = storage.getItem(_keyUserName);
      final savedContact = storage.getItem(_keyUserContact);

      if (savedName != null && savedContact != null) {
        _userInfo = UserInfo(name: savedName, contact: savedContact);

        final savedMessages = storage.getItem(_keyMessages);
        if (savedMessages != null) {
          final List<dynamic> decoded = jsonDecode(savedMessages);
          final messages =
              decoded
                  .map(
                    (m) =>
                        ChatMessage.fromCompactJson(m as Map<String, dynamic>),
                  )
                  .toList();
          if (messages.isNotEmpty) {
            emit(ChatLoaded(messages));
            return;
          }
        }

        _initializeChat();
      }
    } catch (_) {
      // sessionStorage unavailable — fall through to show the form
    }
  }

  void _saveMessages(List<ChatMessage> messages) {
    try {
      final toStore =
          messages.length > _maxStoredMessages
              ? messages.sublist(messages.length - _maxStoredMessages)
              : messages;
      final encoded = jsonEncode(
        toStore.map((m) => m.toCompactJson()).toList(),
      );
      web.window.sessionStorage.setItem(_keyMessages, encoded);
    } catch (_) {}
  }

  void setUserInfo(String name, String contact) {
    _userInfo = UserInfo(name: name, contact: contact);

    try {
      web.window.sessionStorage.setItem(_keyUserName, name);
      web.window.sessionStorage.setItem(_keyUserContact, contact);
    } catch (_) {}

    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      final welcomeMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text:
            'أهلاً بك ${_userInfo!.name}! 👋\n\n'
            'تم تسجيل بياناتك بنجاح ✅\n'
            'رقم التواصل: ${_userInfo!.contact}\n\n'
            'أنا مساعدك الذكي من SingleClic، وأنا هنا لمساعدتك في أي وقت. 🤖\n\n'
            'كيف يمكنني مساعدتك اليوم؟',
        isUser: false,
        timestamp: DateTime.now(),
      );
      final messages = [welcomeMessage];
      _saveMessages(messages);
      emit(ChatLoaded(messages));
    } catch (e) {
      emit(ChatError('Failed to initialize chat: ${e.toString()}', []));
    }
  }

  List<ChatMessage> _currentMessages() {
    final s = state;
    if (s is ChatLoaded) return s.messages;
    if (s is ChatLoading) return s.messages;
    if (s is ChatStreaming) return s.messages;
    if (s is ChatError) return s.messages;
    return [];
  }

  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    _isCancelled = true;
    _wordQueue.clear();

    final currentMessages = _currentMessages();

    final userMsg = ChatMessage(
      id: _generateId(),
      text: userMessage.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    final messagesWithUser = List<ChatMessage>.from(currentMessages)
      ..add(userMsg);
    emit(ChatLoading(messagesWithUser));

    final botMsgId = _generateId();
    final botTimestamp = DateTime.now();
    final displayedText = StringBuffer();
    bool streamDone = false;
    _isCancelled = false;

    final streamingMessages = List<ChatMessage>.from(messagesWithUser);

    Future<void> processQueue() async {
      if (_isProcessing) return;
      _isProcessing = true;

      while (_wordQueue.isNotEmpty) {
        if (isClosed || _isCancelled) break;

        final word = _wordQueue.removeAt(0);
        displayedText.write(word);

        final botMsg = ChatMessage(
          id: botMsgId,
          text: displayedText.toString(),
          isUser: false,
          timestamp: botTimestamp,
        );

        if (streamingMessages.length > messagesWithUser.length) {
          streamingMessages.last = botMsg;
        } else {
          streamingMessages.add(botMsg);
        }

        emit(ChatStreaming(streamingMessages));
        await Future.delayed(_wordDelay);
      }

      _isProcessing = false;

      if (streamDone && _wordQueue.isEmpty && !isClosed && !_isCancelled) {
        final finalText = displayedText.toString();
        if (finalText.isEmpty) {
          emit(ChatError('No response received.', messagesWithUser));
          return;
        }

        final botMsg = ChatMessage(
          id: botMsgId,
          text: finalText,
          isUser: false,
          timestamp: botTimestamp,
        );
        final allMessages = [...messagesWithUser, botMsg];
        _saveMessages(allMessages);
        emit(ChatLoaded(allMessages));
      }
    }

    await _repository.sendMessageStream(
      userMessage,
      userInfo: _userInfo?.toJson(),
      onData: (token) {
        final words = token.split(RegExp(r'(?<=\s)'));
        _wordQueue.addAll(words);
        processQueue();
      },
      onDone: () {
        streamDone = true;
        if (!_isProcessing && _wordQueue.isEmpty) {
          final finalText = displayedText.toString();
          if (finalText.isEmpty) {
            emit(ChatError('No response received.', messagesWithUser));
            return;
          }
          final botMsg = ChatMessage(
            id: botMsgId,
            text: finalText,
            isUser: false,
            timestamp: botTimestamp,
          );
          final allMessages = [...messagesWithUser, botMsg];
          _saveMessages(allMessages);
          emit(ChatLoaded(allMessages));
        }
      },
      onError: (error) {
        _isCancelled = true;
        _wordQueue.clear();
        emit(ChatError('Failed to send message: $error', messagesWithUser));
      },
    );
  }

  @override
  Future<void> close() {
    _isCancelled = true;
    _wordQueue.clear();
    return super.close();
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
