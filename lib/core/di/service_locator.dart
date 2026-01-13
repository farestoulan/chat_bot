import 'package:get_it/get_it.dart';
import '../../core/environments/environment_injector.dart';
import '../../core/environments/environments.dart';
import '../../core/api/dio_injector.dart';
import '../../features/data/datasources/remote_chat_datasource.dart';
import '../../features/data/repositories/chat_repository_impl.dart';
import '../../features/domain/repositories/chat_repository.dart';
import '../../features/presentation/cubit/chat_cubit.dart';
import '../../features/presentation/cubit/theme_cubit.dart';

/// Global service locator
final injector = GetIt.instance;

/// Register all dependencies here.
Future<void> initServiceLocator() async {
  // Initialize environment
  const environment = DevelopmentEnvironment();
  await environmentInjector(environment);

  // Initialize Dio and API dependencies
  await dioInjector(environment);

  // Data sources
  injector.registerLazySingleton<RemoteChatDatasource>(
    () => RemoteChatDatasourceImpl(apiConsumer: injector()),
  );

  // Repositories
  injector.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(datasource: injector()),
  );

  // Cubits / Blocs
  injector.registerFactory<ChatCubit>(
    () => ChatCubit(injector<ChatRepository>()),
  );
  injector.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
}
