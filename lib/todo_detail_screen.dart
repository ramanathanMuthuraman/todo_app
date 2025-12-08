import 'package:flutter/material.dart';

import 'todo/todo_item.dart';
import 'todo/todo_controller.dart';
import 'todo/todo_utils.dart';

class TodoDetailScreen extends StatelessWidget {
  final TodoItem todo;

  const TodoDetailScreen({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    final todos = TodoControllerProvider.of(context);
    const double leftIndent = 48;

    final isOverdue = !todo.isDone && todo.dueDate.isBefore(DateTime.now());
    final timeLeft = timeLeftText(todo.dueDate);

    return Scaffold(
      appBar: AppBar(title: const Text('Todo Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            CheckboxListTile(
              value: todo.isDone,
              onChanged: (value) async {
                await todos.toggleTodo(todo);
              },
              title: Text(
                todo.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  decoration: todo.isDone ? TextDecoration.lineThrough : null,
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),

            // Due date/time
            Padding(
              padding: const EdgeInsets.only(left: leftIndent),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    formatDate(todo.dueDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: leftIndent),
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    formatTime(todo.dueDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Time left / overdue
            Padding(
              padding: const EdgeInsets.only(left: leftIndent),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    todo.isDone ? 'Completed' : timeLeft,
                    style: TextStyle(
                      fontSize: 14,
                      color: todo.isDone
                          ? Colors.green
                          : (isOverdue ? Colors.red : Colors.grey),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Delete button
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete this todo?'),
                      content: const Text('This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    final controller = TodoControllerProvider.of(context);
                    final index = controller.todos.indexOf(todo);
                    if (index != -1) {
                      await controller.deleteAt(index);
                    }
                    if (!context.mounted) return;
                    Navigator.of(context).pop(); // go back after delete
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
