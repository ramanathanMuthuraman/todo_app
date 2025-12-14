import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'theme_controller.dart';
import 'todo_screen.dart'; // your existing file
import 'todo/todo_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeController = ThemeController();
  await themeController.loadInitialTheme();

  // Todo controller
  final todoController = TodoController();
  await todoController.loadTodos(); // 👈 load saved todos

  runApp(
    ThemeControllerProvider(
      controller: themeController,
      child: TodoControllerProvider(controller: todoController, child: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeControllerProvider.of(context);
    return MaterialApp(
      title: 'My Todos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: theme.mode,

      home: TodoScreen(),
    );
  }
}
