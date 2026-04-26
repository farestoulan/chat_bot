import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/web.dart' as web;
import '../../data/datasources/lead_datasource.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/user_info.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;
  final LeadDatasource _leadDatasource;

  /// Delay between displaying each word.
  static const _wordDelay = Duration(milliseconds: 40);

  static const _keyUserName = 'chatbot_user_name';
  static const _keyUserContact = 'chatbot_user_contact';
  static const _keyLeadId = 'chatbot_lead_id';
  static const _keyChatId = 'chatbot_chat_id';
  static const _keyMessages = 'chatbot_messages';
  static const _maxStoredMessages = 25;

  final _wordQueue = <String>[];
  bool _isProcessing = false;
  bool _isCancelled = false;

  UserInfo? _userInfo;
  UserInfo? get userInfo => _userInfo;

  int? _leadId;
  int? get leadId => _leadId;

  String? _chatId;
  String? get chatId => _chatId;

  ChatCubit(this._repository, this._leadDatasource)
      : super(const ChatUserInfoRequired()) {
    _loadSavedSession();
  }

  void _loadSavedSession() {
    try {
      final storage = web.window.sessionStorage;
      final savedName = storage.getItem(_keyUserName);
      final savedContact = storage.getItem(_keyUserContact);

      if (savedName != null && savedContact != null) {
        _userInfo = UserInfo(name: savedName, contact: savedContact);
        final savedLeadId = storage.getItem(_keyLeadId);
        if (savedLeadId != null) {
          _leadId = int.tryParse(savedLeadId);
        }

        final savedChatId = storage.getItem(_keyChatId);
        if (savedChatId != null) {
          _chatId = savedChatId;
        }

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

  void _saveChatId(String chatId) {
    try {
      web.window.sessionStorage.setItem(_keyChatId, chatId);
    } catch (_) {}
  }

  Future<void> setUserInfo(String name, String contact) async {
    _userInfo = UserInfo(name: name, contact: contact);

    emit(const ChatLeadCreating());

    final leadOk = await _createLead(name, contact);

    if (!leadOk) {
      emit(
        ChatLeadCreationFailed(
          _lastLeadErrorMessage ?? 'Failed to create lead',
        ),
      );
      return;
    }

    try {
      web.window.sessionStorage.setItem(_keyUserName, name);
      web.window.sessionStorage.setItem(_keyUserContact, contact);
      if (_leadId != null) {
        web.window.sessionStorage.setItem(_keyLeadId, _leadId.toString());
      }
    } catch (_) {}

    await _initializeChat();
  }

  String? _lastLeadErrorMessage;

  /// Returns `true` only when the lead API succeeds.
  Future<bool> _createLead(String name, String contact) async {
    _lastLeadErrorMessage = null;
    try {
      final result = await _leadDatasource.createLead(
        name: name,
        phone: contact,
      );
      return result.fold(
        (error) {
          _lastLeadErrorMessage = error.message;
          debugPrint('Lead creation failed: ${error.message}');
          return false;
        },
        (response) {
          _leadId = response.leadId;
          if (_leadId != null) {
            try {
              web.window.sessionStorage.setItem(
                _keyLeadId,
                _leadId.toString(),
              );
            } catch (_) {}
          }
          debugPrint('Lead created: id=${response.leadId}');
          return true;
        },
      );
    } catch (e) {
      _lastLeadErrorMessage = e.toString();
      debugPrint('Lead creation error: $e');
      return false;
    }
  }

  void _appendLeadTextToServer(String text) {
    final id = _leadId;
    final trimmed = text.trim();
    if (id == null || trimmed.isEmpty) return;
    unawaited(_appendLeadTextAsync(id, trimmed));
  }

  Future<void> _appendLeadTextAsync(int id, String trimmed) async {
    final result = await _leadDatasource.appendLeadText(
      leadId: id,
      text: trimmed,
    );
    result.fold(
      (e) => debugPrint('Lead append failed: ${e.message}'),
      (r) => debugPrint(
        'Lead append ok: lead_id=${r.leadId ?? id} ${r.message}',
      ),
    );
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

    _appendLeadTextToServer(userMsg.text);

    final botMsgId = _generateId();
    final botTimestamp = DateTime.now();
    final displayedText = StringBuffer();
    bool streamDone = false;
    _isCancelled = false;

    final streamingMessages = List<ChatMessage>.from(messagesWithUser);
    var botStreamFinalized = false;

    void completeBotStreamSuccess() {
      if (botStreamFinalized || isClosed || _isCancelled) return;
      botStreamFinalized = true;
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
      _appendLeadTextToServer(finalText);
      emit(ChatLoaded(allMessages));
    }

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
        completeBotStreamSuccess();
      }
    }

    await _repository.sendMessageStream(
      userMessage,
      chatId: _chatId,
      userInfo: _userInfo?.toJson(),
      onData: (token, receivedChatId) {
        if (receivedChatId != null && _chatId == null) {
          _chatId = receivedChatId;
          _saveChatId(receivedChatId);
          debugPrint('Chat ID received and saved: $receivedChatId');
        }
        final words = token.split(RegExp(r'(?<=\s)'));
        _wordQueue.addAll(words);
        processQueue();
      },
      onDone: () {
        streamDone = true;
        if (!_isProcessing && _wordQueue.isEmpty) {
          completeBotStreamSuccess();
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
