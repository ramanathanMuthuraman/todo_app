import 'package:flutter/material.dart';

import 'theme_controller.dart';
import 'todo/todo_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeControllerProvider.of(context);
    final todos = TodoControllerProvider.of(context);

    final isDark = theme.isDark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme section
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Dark mode'),
            subtitle: const Text('Toggle light / dark theme'),
            trailing: Switch(
              value: isDark,
              onChanged: (_) {
                theme.toggle();
              },
            ),
          ),
          const Divider(),

          // Clear todos section
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Clear all todos'),
            subtitle: const Text('Remove all tasks permanently'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_forever),
              color: Colors.red,
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Clear all todos?'),
                      content: const Text(
                        'This will delete all your tasks. This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text(
                            'Clear',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );

                if (confirmed == true) {
                  await todos.clearAll();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All todos cleared')),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
