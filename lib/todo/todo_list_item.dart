import 'package:flutter/material.dart';
import 'todo_utils.dart';

class TodoListItem extends StatelessWidget {
  final String title;
  final DateTime dueDate;
  final bool isDone;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback? onTap;

  const TodoListItem({
    super.key,
    required this.title,
    required this.dueDate,
    required this.isDone,
    required this.onToggle,
    required this.onEdit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOverdue = !isDone && dueDate.isBefore(DateTime.now());
    final String timeLeft = timeLeftText(dueDate);

    return TweenAnimationBuilder<double>(
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: AnimatedScale(
        scale: isDone ? 0.96 : 1.0, // <<-- NEW
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Card(
            elevation: 2,
            color: isDone ? Colors.grey[200] : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              onTap: onTap,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              leading: IconButton(
                icon: Icon(
                  isDone ? Icons.check_box : Icons.check_box_outline_blank,
                  color: Colors.blue,
                ),
                onPressed: onToggle,
              ),
              title: Text(
                title,
                style: TextStyle(
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  color: isDone
                      ? Colors.grey
                      : (isOverdue ? Colors.red : Colors.black),
                  fontSize: 18,
                ),
              ),
              subtitle: Row(
                children: [
                  Text('${formatDate(dueDate)} • ${formatTime(dueDate)}'),
                  if (!isDone) ...[
                    const SizedBox(width: 8),
                    Text(
                      timeLeft,
                      style: TextStyle(
                        color: isOverdue ? Colors.red : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: onEdit,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
