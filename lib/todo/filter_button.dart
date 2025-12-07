import 'package:flutter/material.dart';

import 'todo_controller.dart'; // adjust path if needed

class FilterButton extends StatelessWidget {
  final String label;
  final FilterType type;

  const FilterButton({super.key, required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    final todos = TodoControllerProvider.of(context);
    final bool selected = todos.filter == type;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? Colors.blue : Colors.grey[300],
        foregroundColor: selected ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () {
        todos.setFilter(type);
      },
      child: Text(label),
    );
  }
}
