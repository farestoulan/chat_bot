import 'package:dio/dio.dart';

import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:chat_bot/core/api/api_consumer.dart';
import 'package:chat_bot/core/api/app_interceptor.dart';
import 'package:chat_bot/core/api/dio_consumer.dart';
import 'package:chat_bot/core/api/network_info.dart';
import 'package:chat_bot/core/di/service_locator.dart';
import 'package:chat_bot/core/environments/environments.dart';

Future<void> dioInjector(Environment environment) async {
  // Register interceptors
  injector.registerLazySingleton(() => AppInterceptor());

  // Register log interceptor for debugging
  injector.registerLazySingleton(
    () => LogInterceptor(requestBody: true, responseBody: true),
  );

  // Register internet connection checker
  injector.registerLazySingleton(() => InternetConnectionChecker());

  // Register Dio instance with interceptors
  injector.registerLazySingleton(() {
    final dio = Dio(BaseOptions(baseUrl: environment.baseUrl));

    // Add interceptors
    dio.interceptors.add(injector<AppInterceptor>());
    dio.interceptors.add(injector<LogInterceptor>());

    return dio;
  });

  // Register NetworkInfo
  injector.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectionChecker: injector()),
  );

  // Register ApiConsumer
  injector.registerLazySingleton<ApiConsumer>(
    () => DioConsumer(client: injector()),
  );
}
