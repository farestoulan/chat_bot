import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../core/constants/app_constants.dart';
import '../../../core/error_handling/exceptions.dart';
import '../models/lead_response.dart';

abstract class LeadDatasource {
  Future<Either<NetworkException, LeadResponse>> createLead({
    required String name,
    required String phone,
    String? text,
  });

  /// Appends [text] to an existing lead (same path as create; body uses `id` + `text`).
  Future<Either<NetworkException, LeadResponse>> appendLeadText({
    required int leadId,
    required String text,
  });
}

class LeadDatasourceImpl implements LeadDatasource {
  LeadDatasourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<Either<NetworkException, LeadResponse>> createLead({
    required String name,
    required String phone,
    String? text,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.leadApiEffectivePath,
        data: _createLeadBody(name: name, phone: phone, text: text),
      );

      final leadResponse = LeadResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      return _resultFromLeadResponse(leadResponse);
    } on DioException catch (e) {
      return Left(_mapDioException(e));
    } catch (e) {
      return Left(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<Either<NetworkException, LeadResponse>> appendLeadText({
    required int leadId,
    required String text,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.leadApiEffectivePath,
        data: <String, dynamic>{
          'id': leadId,
          'text': text,
        },
      );

      final leadResponse = LeadResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      return _resultFromLeadResponse(leadResponse);
    } on DioException catch (e) {
      return Left(_mapDioException(e));
    } catch (e) {
      return Left(NetworkException(message: e.toString()));
    }
  }

  static Map<String, dynamic> _createLeadBody({
    required String name,
    required String phone,
    String? text,
  }) => {
    'name': name,
    'phone': phone,
    'text': text ?? AppConstants.defaultLeadText,
  };

  Either<NetworkException, LeadResponse> _resultFromLeadResponse(
    LeadResponse leadResponse,
  ) {
    if (leadResponse.success) {
      return Right(leadResponse);
    }
    return Left(
      NetworkException(
        message: leadResponse.message.isNotEmpty
            ? leadResponse.message
            : 'Failed to create lead',
      ),
    );
  }

  NetworkException _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: 'Connection timeout. Please try again.',
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        String message = 'An error occurred';

        if (data is Map) {
          if (data.containsKey('error')) {
            message = data['error'].toString();
          } else if (data.containsKey('message')) {
            message = data['message'].toString();
          }
        } else if (statusCode == 401) {
          message = 'Unauthorized. Invalid API key.';
        } else if (statusCode == 400) {
          message = 'Bad request. Please check your input.';
        } else if (statusCode == 500) {
          message = 'Server error. Please try again later.';
        }

        return NetworkException(
          message: message,
          statusCode: statusCode,
          data: data,
        );
      case DioExceptionType.cancel:
        return NetworkException(
          message: 'Request cancelled',
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.connectionError:
        return NetworkException(
          message: kIsWeb
              ? 'Cannot reach lead API from the browser (often CORS). '
                  'The Odoo server must allow your app origin and '
                  'Authorization, Content-Type, Accept in CORS headers. '
                  'Or test from Windows/Android/iOS build instead of web.'
              : 'Could not connect to the lead server. Check network and URL.',
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.badCertificate:
        return NetworkException(
          message: 'Invalid SSL certificate from server.',
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.unknown:
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
}
