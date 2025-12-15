import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/chat_repository_impl.dart';
import 'presentation/cubit/chat_cubit.dart';
import 'presentation/screens/chat_screen.dart';

void main() {
  runApp(const ChatBotApp());
}

class ChatBotApp extends StatelessWidget {
  const ChatBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dependency injection - create repository and cubit
    final repository = ChatRepositoryImpl();
    final cubit = ChatCubit(repository);

    return MaterialApp(
      title: 'ChatBot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: BlocProvider<ChatCubit>.value(
        value: cubit,
        child: const ChatScreen(),
      ),
    );
  }
}
