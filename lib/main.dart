import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/di/service_locator.dart';
import 'core/bloc_observer/bloc_observer.dart';
import 'features/presentation/cubit/chat_cubit.dart';
import 'features/presentation/cubit/theme_cubit.dart';
import 'features/presentation/screens/chat_screen.dart';

void main() async {
  // Initialize BlocObserver to see states in terminal
  Bloc.observer = AppBlocObserver();

  // Initialize dependency injection
  await initServiceLocator();

  runApp(const ChatBotApp());
}

class ChatBotApp extends StatelessWidget {
  const ChatBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChatCubit>(create: (_) => injector<ChatCubit>()),
        BlocProvider<ThemeCubit>(create: (_) => injector<ThemeCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'ChatBot',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const ChatScreen(),
          );
        },
      ),
    );
  }
}
// "chat_id": "ccf8a0f1-2735-4f42-abd9-77386054644c"
//"chat_id": "3ccf7249-5cd2-42f4-9548-adbb984b49a1"