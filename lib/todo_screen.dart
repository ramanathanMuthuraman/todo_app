import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoItem {
  String title;
  final String dayLabel;
  final String timeLabel;
  bool isDone;

  _TodoItem({
    required this.title,
    required this.dayLabel,
    required this.timeLabel,
    this.isDone = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dayLabel': dayLabel,
      'timeLabel': timeLabel,
      'isDone': isDone,
    };
  }

  factory _TodoItem.fromMap(Map<String, dynamic> map) {
    return _TodoItem(
      title: map['title'] as String,
      dayLabel: map['dayLabel'] as String,
      timeLabel: map['timeLabel'] as String,
      isDone: map['isDone'] as bool,
    );
  }
}

class _TodoScreenState extends State<TodoScreen> {
  final List<_TodoItem> _todos = [];
  final TextEditingController _taskController = TextEditingController();
  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('todos_v1');

    if (jsonString == null) {
      // optional initial sample data for first run
      setState(() {
        _todos.addAll([
          _TodoItem(
            title: "Buy groceries",
            dayLabel: "Today",
            timeLabel: "6 PM",
          ),
          _TodoItem(
            title: "Finish Flutter UI",
            dayLabel: "Today",
            timeLabel: "8 PM",
          ),
          _TodoItem(
            title: "Read a book",
            dayLabel: "Tomorrow",
            timeLabel: "9 PM",
          ),
        ]);
      });
      await _saveTodos();
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // so it can move up with keyboard
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom:
                MediaQuery.of(context).viewInsets.bottom + 16, // keyboard-safe
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
                    onPressed: () {
                      final newText = controller.text.trim();
                      if (newText.isEmpty) {
                        Navigator.of(context).pop();
                        return;
                      }

                      setState(() {
                        item.title = newText;
                      });

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Todos")),
      body: Align(
        alignment: Alignment.topLeft,

        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Today'),
              Text(DateTime.now().toString()),
              const SizedBox(height: 10.0),
              Center(
                child: Row(
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

                    // Add Button
                    Container(
                      margin: EdgeInsets.only(left: 10),
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
                              _TodoItem(
                                title: text,
                                dayLabel: "Today",
                                timeLabel: "6 PM",
                              ),
                            );
                          });

                          _taskController.clear();
                          await _saveTodos();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: ListView.builder(
                    itemCount: _todos.length,
                    itemBuilder: (context, index) {
                      final item = _todos[index];
                      return Dismissible(
                        key: ValueKey(item.title), // ok for now
                        direction:
                            DismissDirection.endToStart, // swipe right → left
                        onDismissed: (direction) async {
                          // store title before removing
                          final removedTitle = item.title;

                          setState(() {
                            _todos.removeAt(index);
                          });
                          await _saveTodos();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$removedTitle deleted')),
                          );
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: _TodoListItem(
                          title: item.title,
                          dayLabel: item.dayLabel,
                          timeLabel: item.timeLabel,
                          isDone: item.isDone,
                          onEdit: () => _openEditBottomSheet(item),
                          onToggle: () async {
                            setState(() {
                              item.isDone = !item.isDone;
                              _todos.sort((a, b) {
                                if (a.isDone == b.isDone) return 0;
                                return a.isDone ? 1 : -1;
                              });
                            });
                            await _saveTodos();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodoListItem extends StatelessWidget {
  final String title;
  final String dayLabel;
  final String timeLabel;
  final bool isDone;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  const _TodoListItem({
    super.key,
    required this.title,
    required this.dayLabel,
    required this.timeLabel,
    required this.isDone,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
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
          color: isDone ? Colors.grey : Colors.black,
          fontSize: 18,
        ),
      ),
      subtitle: Row(
        children: [
          Text(
            dayLabel,
            style: TextStyle(color: isDone ? Colors.grey : Colors.black54),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.access_time, size: 16),
          const SizedBox(width: 6),
          Text(timeLabel),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: onEdit, // 👈 call the callback
      ),
    );
  }
}
