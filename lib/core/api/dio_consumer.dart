import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:chat_bot/core/api/api_consumer.dart';
import 'package:chat_bot/core/api/status_code.dart';
import 'package:chat_bot/core/error_handling/exceptions.dart';

/// Dio implementation of ApiConsumer
class DioConsumer implements ApiConsumer {
  final Dio client;

  DioConsumer({required this.client});

  @override
  Future<Either<NetworkException, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool? isResponseTypeHtml,
  }) async {
    try {
      final response = await client.get(
        path,
        queryParameters: queryParameters,
        options: Options(
          responseType: isResponseTypeHtml == true
              ? ResponseType.plain
              : ResponseType.json,
        ),
      );
      return Right(response.data);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<Either<NetworkException, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool formDataIsEnabled = false,
  }) async {
    try {
      final response = await client.post(
        path,
        data: formDataIsEnabled ? FormData.fromMap(body ?? {}) : body,
        queryParameters: queryParameters,
        options: options,
      );
      return Right(response.data);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<Either<NetworkException, dynamic>> put(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool formDataIsEnabled = false,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await client.put(
        path,
        data: formDataIsEnabled ? FormData.fromMap(body ?? {}) : body,
        queryParameters: queryParameters,
        options: options,
      );
      return Right(response.data);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<Either<NetworkException, dynamic>> delete(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool formDataIsEnabled = false,
  }) async {
    try {
      final response = await client.delete(
        path,
        data: formDataIsEnabled ? FormData.fromMap(body ?? {}) : body,
        queryParameters: queryParameters,
        options: options,
      );
      return Right(response.data);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<Either<NetworkException, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool formDataIsEnabled = false,
  }) async {
    try {
      final response = await client.patch(
        path,
        data: formDataIsEnabled ? FormData.fromMap(body ?? {}) : body,
        queryParameters: queryParameters,
        options: options,
      );
      return Right(response.data);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(NetworkException(message: e.toString()));
    }
  }

  NetworkException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: 'Connection timeout. Please try again.',
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.badResponse:
        return NetworkException(
          message: _getErrorMessage(error.response?.statusCode, error.response?.data),
          statusCode: error.response?.statusCode,
          data: error.response?.data,
        );
      case DioExceptionType.cancel:
        return NetworkException(
          message: 'Request cancelled',
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.unknown:
      default:
        if (error.message?.contains('SocketException') ?? false) {
          return NetworkException(
            message: 'No internet connection. Please check your network.',
            statusCode: error.response?.statusCode,
          );
        }
        return NetworkException(
          message: error.message ?? 'An unexpected error occurred',
          statusCode: error.response?.statusCode,
        );
    }
  }

  String _getErrorMessage(int? statusCode, dynamic data) {
    switch (statusCode) {
      case StatusCode.badRequest:
        return 'Bad request. Please check your input.';
      case StatusCode.unauthorized:
        return 'Unauthorized. Please login again.';
      case StatusCode.forbidden:
        return 'Forbidden. You don\'t have permission.';
      case StatusCode.notFound:
        return 'Resource not found.';
      case StatusCode.conflict:
        return 'Conflict. The resource already exists.';
      case StatusCode.internalServerError:
        return 'Internal server error. Please try again later.';
      case StatusCode.serverDownError:
        return 'Server is down. Please try again later.';
      default:
        if (data is Map && data.containsKey('message')) {
          return data['message'].toString();
        }
        return 'An error occurred. Please try again.';
    }
  }
}

