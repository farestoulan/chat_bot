import 'package:dio/dio.dart';
import 'package:chat_bot/core/api/dio_strings.dart';

class AppInterceptor extends Interceptor {
  AppInterceptor();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Set default headers only if not already set
    if (!options.headers.containsKey(DioStrings.contentType)) {
      options.headers[DioStrings.contentType] = DioStrings.applicationJson;
    }
    if (!options.headers.containsKey('Accept')) {
      options.headers['Accept'] = DioStrings.applicationJson;
    }

    super.onRequest(options, handler);
  }
}
