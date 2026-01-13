import 'package:chat_bot/core/di/service_locator.dart';
import 'package:chat_bot/core/environments/environments.dart';

Future<void> environmentInjector(Environment environment) async {
  injector.registerLazySingleton(() => environment);
}
