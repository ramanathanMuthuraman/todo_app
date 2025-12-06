import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'theme_controller.dart';
import 'todo_screen.dart'; // your existing file

void main() async {
  final themeController = ThemeController();
  await themeController.loadInitialTheme();
  runApp(
    ThemeControllerProvider(controller: themeController, child: const MyApp()),
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
