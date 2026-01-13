import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:chat_bot/core/error_handling/exceptions.dart';

abstract class ApiConsumer {
  Future<Either<NetworkException, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool? isResponseTypeHtml,
  });

  Future<Either<NetworkException, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool formDataIsEnabled = false,
  });

  Future<Either<NetworkException, dynamic>> put(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool formDataIsEnabled = false,
    Map<String, dynamic>? body,
  });

  Future<Either<NetworkException, dynamic>> delete(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool formDataIsEnabled = false,
  });

  Future<Either<NetworkException, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool formDataIsEnabled = false,
  });
}
