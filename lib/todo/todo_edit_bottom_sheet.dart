import 'package:flutter/material.dart';

import 'todo_item.dart';
import 'todo_controller.dart';
import 'todo_utils.dart';

Future<void> showEditTodoBottomSheet(BuildContext context, TodoItem item) {
  final textController = TextEditingController(text: item.title);
  DateTime tempDueDate = item.dueDate;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (sheetContext, setModalState) {
          Future<void> pickDate() async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: sheetContext,
              initialDate: tempDueDate,
              firstDate: DateTime(now.year - 1),
              lastDate: DateTime(now.year + 2),
            );

            if (picked != null) {
              setModalState(() {
                tempDueDate = DateTime(
                  picked.year,
                  picked.month,
                  picked.day,
                  tempDueDate.hour,
                  tempDueDate.minute,
                );
              });
            }
          }

          Future<void> pickTime() async {
            final picked = await showTimePicker(
              context: sheetContext,
              initialTime: TimeOfDay.fromDateTime(tempDueDate),
            );

            if (picked != null) {
              setModalState(() {
                tempDueDate = DateTime(
                  tempDueDate.year,
                  tempDueDate.month,
                  tempDueDate.day,
                  picked.hour,
                  picked.minute,
                );
              });
            }
          }

          final todos = TodoControllerProvider.of(sheetContext);

          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Edit task",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    labelText: "Task title",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Due: ${formatDate(tempDueDate)} • ${formatTime(tempDueDate)}",
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: pickDate,
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: const Text("Pick date"),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: pickTime,
                      icon: const Icon(Icons.access_time, size: 18),
                      label: const Text("Pick time"),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                      },
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final newText = textController.text.trim();
                        if (newText.isEmpty) {
                          Navigator.of(sheetContext).pop();
                          return;
                        }

                        await todos.updateTodo(item, newText, tempDueDate);

                        if (!sheetContext.mounted) return;
                        Navigator.of(sheetContext).pop();
                      },
                      child: const Text("Save"),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
