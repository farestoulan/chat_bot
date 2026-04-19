import 'package:chat_bot/core/api/dio_strings.dart';
import 'package:dio/dio.dart';

/// Default JSON headers for the main [Dio] client (chat API). Lead API uses its own Dio + Bearer.
class AppInterceptor extends Interceptor {
  AppInterceptor();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!options.headers.containsKey(DioStrings.contentType)) {
      options.headers[DioStrings.contentType] = DioStrings.applicationJson;
    }
    if (!options.headers.containsKey('Accept')) {
      options.headers['Accept'] = DioStrings.applicationJson;
    }

    super.onRequest(options, handler);
  }
}
