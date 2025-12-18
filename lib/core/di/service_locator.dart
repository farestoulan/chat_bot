import 'package:get_it/get_it.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../presentation/cubit/chat_cubit.dart';
import '../../presentation/cubit/theme_cubit.dart';

/// Global service locator
final sl = GetIt.instance;

/// Register all dependencies here.
void initServiceLocator() {
  // Repositories
  sl.registerLazySingleton<ChatRepositoryImpl>(() => ChatRepositoryImpl());

  // Cubits / Blocs
  sl.registerFactory<ChatCubit>(() => ChatCubit(sl<ChatRepositoryImpl>()));
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
}
