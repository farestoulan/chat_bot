import 'package:chat_bot/core/bloc_observer/bloc_observer.dart';
import 'package:chat_bot/core/di/service_locator.dart';

Future<void> blocObserverInjector() async {
  injector.registerLazySingleton(() => AppBlocObserver());
}
