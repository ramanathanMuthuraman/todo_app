import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'theme_controller.dart';

enum FilterType { all, pending, completed }

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoItem {
  String title;
  DateTime dueDate;
  bool isDone;

  _TodoItem({required this.title, required this.dueDate, this.isDone = false});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'isDone': isDone,
    };
  }

  factory _TodoItem.fromMap(Map<String, dynamic> map) {
    return _TodoItem(
      title: map['title'] as String,
      dueDate: DateTime.parse(map['dueDate'] as String),
      isDone: map['isDone'] as bool,
    );
  }
}

class _TodoScreenState extends State<TodoScreen> {
  final List<_TodoItem> _todos = [];
  final TextEditingController _taskController = TextEditingController();

  final TextEditingController _searchController = TextEditingController();

  List<_TodoItem> _visibleTodos = [];

  Timer? _searchDebounce;

  FilterType _filter = FilterType.all;

  void _onSearchChanged(String text) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      _applyFilters();
    });
  }

  @override
  void dispose() {
    _taskController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadTodos();
    _visibleTodos = List.from(_todos);
  }

  void _sortTodos() {
    _todos.sort((a, b) {
      // Pending first
      if (a.isDone != b.isDone) {
        return a.isDone ? 1 : -1;
      }

      // Within pending or completed → sort by due date
      return a.dueDate.compareTo(b.dueDate);
    });
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('todos_v1');

    if (jsonString == null) {
      return;
    }

    final List decoded = jsonDecode(jsonString) as List;

    final loaded = decoded
        .map((e) => _TodoItem.fromMap(e as Map<String, dynamic>))
        .toList();

    setState(() {
      _todos
        ..clear()
        ..addAll(loaded);
      _sortTodos();
      _applyFilters();
    });
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _todos.map((t) => t.toMap()).toList();
    final jsonString = jsonEncode(list);
    await prefs.setString('todos_v1', jsonString);
  }

  void _openEditBottomSheet(_TodoItem item) {
    final controller = TextEditingController(text: item.title);

    DateTime tempDueDate = item.dueDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // so it can move up with keyboard
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickDate() async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
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
                context: context,
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

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom +
                    16, // keyboard-safe
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
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: "Task title",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  Text(
                    "Due: ${formatDate(tempDueDate)} • ${formatTime(tempDueDate)}",
                    style: const TextStyle(color: Colors.grey),
                  ),
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
                          Navigator.of(context).pop(); // close sheet
                        },
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final newText = controller.text.trim();
                          if (newText.isEmpty) {
                            Navigator.of(context).pop();
                            return;
                          }

                          setState(() {
                            item.title = newText;
                            item.dueDate = tempDueDate;
                            _sortTodos();
                            _applyFilters();
                          });

                          await _saveTodos();

                          if (!context.mounted) return;

                          Navigator.of(context).pop();
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

  Widget _buildFilterButton(String label, FilterType type) {
    final bool selected = _filter == type;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? Colors.blue : Colors.grey[300],
        foregroundColor: selected ? Colors.white : Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
      onPressed: () {
        setState(() {
          _filter = type;
        });
        _applyFilters();
      },
      child: Text(label),
    );
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      _visibleTodos = _todos.where((item) {
        // Search filter
        final matchesSearch = item.title.toLowerCase().contains(query);

        // Status filter
        final matchesFilter =
            _filter == FilterType.all ||
            (_filter == FilterType.pending && !item.isDone) ||
            (_filter == FilterType.completed && item.isDone);

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = _visibleTodos;
    final theme = ThemeControllerProvider.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("My Todos"),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(theme.isDark ? Icons.dark_mode : Icons.light_mode),
            onPressed: theme.toggle,
            tooltip: 'Toggle theme',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1) Add new task row
            Row(
              children: [
                // Text Input Box (takes remaining space)
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      hintText: "Add a new task",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Add Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () async {
                      final text = _taskController.text.trim();
                      if (text.isEmpty) return;

                      setState(() {
                        _todos.add(
                          _TodoItem(title: text, dueDate: DateTime.now()),
                        );
                        _sortTodos();
                        _applyFilters();
                      });

                      _taskController.clear();
                      await _saveTodos();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 2) Search field
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search tasks...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),

            const SizedBox(height: 8),

            // 3) Filter buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFilterButton("All", FilterType.all),
                const SizedBox(width: 8),
                _buildFilterButton("Pending", FilterType.pending),
                const SizedBox(width: 8),
                _buildFilterButton("Completed", FilterType.completed),
              ],
            ),

            const SizedBox(height: 12),

            // 4) List / Empty state — must be Expanded
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Text(
                        (_todos.isEmpty &&
                                _searchController.text.trim().isEmpty &&
                                _filter == FilterType.all)
                            ? 'No tasks yet. Add your first one above!'
                            : 'No tasks match your search/filter.',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final item = list[index];

                        return Dismissible(
                          key: ValueKey(
                            '${item.title}_${item.dueDate.toIso8601String()}',
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) async {
                            final removedTitle = item.title;

                            setState(() {
                              _todos.removeAt(index);
                              _applyFilters();
                            });
                            await _saveTodos();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('$removedTitle deleted')),
                            );
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            color: Colors.red,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: _TodoListItem(
                            key: ValueKey(
                              '${item.title}_${item.dueDate.toIso8601String()}',
                            ),
                            title: item.title,
                            dueDate: item.dueDate,
                            isDone: item.isDone,
                            onEdit: () => _openEditBottomSheet(item),
                            onToggle: () async {
                              setState(() {
                                item.isDone = !item.isDone;
                                _sortTodos();
                                _applyFilters();
                              });
                              await _saveTodos();
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodoListItem extends StatelessWidget {
  final String title;
  final DateTime dueDate;
  final bool isDone;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  const _TodoListItem({
    super.key,
    required this.title,
    required this.dueDate,
    required this.isDone,
    required this.onToggle,
    required this.onEdit,
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

String formatDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final pickedDate = DateTime(date.year, date.month, date.day);

  if (pickedDate == today) return "Today";
  if (pickedDate == tomorrow) return "Tomorrow";

  return DateFormat('E, MMM d').format(date); // Example: Mon, Feb 12
}

String formatTime(DateTime dt) {
  return DateFormat('h:mm a').format(dt); // 6:30 PM
}

String timeLeftText(DateTime due) {
  final now = DateTime.now();
  final diff = due.difference(now);

  if (diff.inSeconds.abs() < 60) return diff.isNegative ? 'overdue' : 'now';

  // If overdue
  if (diff.isNegative) {
    final h = diff.inHours.abs();
    final m = diff.inMinutes.abs() % 60;
    if (h > 0) return 'overdue ${h}h ${m}m';
    return 'overdue ${m}m';
  }

  // If upcoming
  if (diff.inDays >= 1) return 'in ${diff.inDays}d';
  if (diff.inHours >= 1) return 'in ${diff.inHours}h';
  return 'in ${diff.inMinutes}m';
}
