import 'package:dio/dio.dart';
import 'package:chat_bot/core/api/dio_strings.dart';

class AppInterceptor extends Interceptor {
  AppInterceptor();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Set default headers
    options.headers[DioStrings.contentType] = DioStrings.applicationJson;
    options.headers['Accept'] = DioStrings.applicationJson;

    super.onRequest(options, handler);
  }
}
