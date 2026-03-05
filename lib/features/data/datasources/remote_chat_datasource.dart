import 'dart:convert';
import '../../../../core/api/api_consumer.dart';

abstract class RemoteChatDatasource {
  Future<void> sendMessageStream(
    String query, {
    Map<String, dynamic>? userInfo,
    required Function(String token) onData,
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
    Map<String, dynamic>? userInfo,
    required Function(String token) onData,
    required Function() onDone,
    required Function(dynamic error) onError,
  }) async {
    final lineBuffer = StringBuffer();

    final body = <String, dynamic>{'query': query};
    if (userInfo != null) {
      body.addAll(userInfo);
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
            bufferContent.endsWith('\n') ? lines : lines.sublist(0, lines.length - 1);

        if (!bufferContent.endsWith('\n')) {
          lineBuffer.write(lines.last);
        }

        for (final line in completeLines) {
          final trimmed = line.trim();
          if (trimmed.isEmpty) continue;

          final content = _extractContent(trimmed);
          if (content != null) {
            onData(content);
          }
        }
      },
      onDone: () {
        if (lineBuffer.isNotEmpty) {
          final content = _extractContent(lineBuffer.toString().trim());
          if (content != null) onData(content);
        }
        onDone();
      },
      onError: onError,
    );
  }

  /// Tries to extract the text content from an SSE data line.
  /// Falls back to returning the raw line if it's not SSE formatted.
  String? _extractContent(String line) {
    if (line.startsWith('data: ')) {
      final jsonStr = line.substring(6).trim();
      if (jsonStr.isEmpty) return null;
      try {
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        if (data.containsKey('content')) {
          final content = data['content'];
          if (content is String && content.isNotEmpty) return content;
          return null;
        }
      } catch (_) {
        return jsonStr;
      }
    }
    return null;
  }
}
