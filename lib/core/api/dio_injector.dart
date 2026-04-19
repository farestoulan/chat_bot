// ignore_for_file: avoid_print — Lead API base URL is logged on web for CORS debugging.
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:chat_bot/core/api/api_consumer.dart';
import 'package:chat_bot/core/api/app_interceptor.dart';
import 'package:chat_bot/core/api/dio_consumer.dart';
import 'package:chat_bot/core/api/network_info.dart';
import 'package:chat_bot/core/constants/app_constants.dart';
import 'package:chat_bot/core/di/service_locator.dart';
import 'package:chat_bot/core/environments/environments.dart';

/// [GetIt] name for the Lead/Odoo [Dio] client (separate base URL and auth).
const String leadApiDioName = 'leadApiDio';

Dio createLeadApiDio() {
  final baseUrl = AppConstants.leadApiEffectiveBaseUrl;
  if (kIsWeb) {
    print(
      '[Lead API] Effective base URL: $baseUrl '
      '${baseUrl == AppConstants.odooBaseUrl ? "(direct Odoo — CORS must be enabled on server)" : "(dart-define override)"}',
    );
  }
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {'Authorization': 'Bearer ${AppConstants.odooApiKey}'},
    ),
  );
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
    ),
  );
  return dio;
}

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
    final dio = Dio(
      BaseOptions(
        baseUrl: environment.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    // Add interceptors
    dio.interceptors.addAll([
      injector<AppInterceptor>(),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
      ),
    ]);
    return dio;
  });

  injector.registerLazySingleton<Dio>(
    createLeadApiDio,
    instanceName: leadApiDioName,
  );

  // Register NetworkInfo
  injector.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectionChecker: injector()),
  );

  // Register ApiConsumer
  injector.registerLazySingleton<ApiConsumer>(
    () => DioConsumer(client: injector()),
  );
}
