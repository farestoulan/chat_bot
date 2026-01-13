import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/api/api_consumer.dart';
import '../../../../core/error_handling/exceptions.dart';

/// Remote data source for chat API
abstract class RemoteChatDatasource {
  Future<Either<NetworkException, String>> sendMessage(String query);
}

class RemoteChatDatasourceImpl implements RemoteChatDatasource {
  final ApiConsumer apiConsumer;

  RemoteChatDatasourceImpl({required this.apiConsumer});

  @override
  Future<Either<NetworkException, String>> sendMessage(String query) async {
    final result = await apiConsumer.post(
      '/chat/stream',
      body: {'query': query},
      // options: Options(responseType: ResponseType.stream),
    );

    return result.fold((error) => Left(error), (data) {
      try {
        // If data is a string, parse it as SSE format
        if (data is String) {
          StringBuffer contentBuffer = StringBuffer();
          final lines = data.split('\n');

          for (final line in lines) {
            final trimmedLine = line.trim();
            if (trimmedLine.startsWith('data: ')) {
              final jsonStr =
                  trimmedLine.substring(6).trim(); // Remove "data: " prefix
              if (jsonStr.isNotEmpty) {
                try {
                  final jsonData = json.decode(jsonStr) as Map<String, dynamic>;
                  // Extract content if available
                  if (jsonData.containsKey('content')) {
                    contentBuffer.write(jsonData['content']);
                  }
                } catch (e) {
                  // Skip invalid JSON lines (like chat_id lines)
                  continue;
                }
              }
            }
          }

          final fullContent = contentBuffer.toString();
          if (fullContent.isNotEmpty) {
            return Right(fullContent);
          }
        }

        // Fallback: try to parse as regular JSON
        if (data is Map && data.containsKey('content')) {
          return Right(data['content'].toString());
        }

        return Left(
          NetworkException(
            message: 'Invalid response format: No content found',
          ),
        );
      } catch (e) {
        return Left(
          NetworkException(message: 'Error parsing response: ${e.toString()}'),
        );
      }
    });
  }
}
