import 'dart:convert';
import '../../../../core/api/api_consumer.dart';

abstract class RemoteChatDatasource {
  Future<void> sendMessageStream(
    String query, {
    String? chatId,
    Map<String, dynamic>? userInfo,
    required Function(String token, String? chatId) onData,
    required Function() onDone,
    required Function(dynamic error) onError,
  });
}

class RemoteChatDatasourceImpl implements RemoteChatDatasource {
  final ApiConsumer apiConsumer;

  RemoteChatDatasourceImpl({required this.apiConsumer});

  @override
  Future<void> sendMessageStream(
    String query, {
    String? chatId,
    Map<String, dynamic>? userInfo,
    required Function(String token, String? chatId) onData,
    required Function() onDone,
    required Function(dynamic error) onError,
  }) async {
    final lineBuffer = StringBuffer();

    final body = <String, dynamic>{'query': query};
    if (chatId != null) {
      body['session_id'] = chatId;
    }

    await apiConsumer.postStream(
      '/chat/stream',
      body: body,
      onData: (chunk) {
        lineBuffer.write(chunk);
        final bufferContent = lineBuffer.toString();
        final lines = bufferContent.split('\n');

        lineBuffer.clear();

        final completeLines =
            bufferContent.endsWith('\n')
                ? lines
                : lines.sublist(0, lines.length - 1);

        if (!bufferContent.endsWith('\n')) {
          lineBuffer.write(lines.last);
        }

        for (final line in completeLines) {
          final trimmed = line.trim();
          if (trimmed.isEmpty) continue;

          final parsed = _parseResponse(trimmed);
          if (parsed != null) {
            onData(parsed.content, parsed.chatId);
          }
        }
      },
      onDone: () {
        if (lineBuffer.isNotEmpty) {
          final parsed = _parseResponse(lineBuffer.toString().trim());
          if (parsed != null) onData(parsed.content, parsed.chatId);
        }
        onDone();
      },
      onError: onError,
    );
  }

  _ParsedResponse? _parseResponse(String line) {
    String jsonStr = line;
    if (line.startsWith('data: ')) {
      jsonStr = line.substring(6).trim();
    }
    if (jsonStr.isEmpty) return null;

    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final content = data['content'];
      final chatId = data['chat_id'];

      if (content is String && content.isNotEmpty) {
        return _ParsedResponse(
          content: content,
          chatId: chatId is String ? chatId : null,
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

class _ParsedResponse {
  final String content;
  final String? chatId;

  _ParsedResponse({required this.content, this.chatId});
}
