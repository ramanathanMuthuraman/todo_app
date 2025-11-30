import 'package:flutter/material.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoItem {
  final String title;
  final String dayLabel;
  final String timeLabel;
  bool isDone;

  _TodoItem({
    required this.title,
    required this.dayLabel,
    required this.timeLabel,
    this.isDone = false,
  });
}

class _TodoScreenState extends State<TodoScreen> {
  final List<_TodoItem> _todos = [
    _TodoItem(title: "Buy groceries", dayLabel: "Today", timeLabel: "6 PM"),
    _TodoItem(title: "Finish Flutter UI", dayLabel: "Today", timeLabel: "8 PM"),
    _TodoItem(title: "Read a book", dayLabel: "Tomorrow", timeLabel: "9 PM"),
  ];
  final TextEditingController _taskController = TextEditingController();
  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
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
                        onPressed: () {
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
                        onDismissed: (direction) {
                          // store title before removing
                          final removedTitle = item.title;

                          setState(() {
                            _todos.removeAt(index);
                          });

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
                          onToggle: () {
                            setState(() {
                              item.isDone = !item.isDone;
                              _todos.sort((a, b) {
                                if (a.isDone == b.isDone) return 0;
                                return a.isDone ? 1 : -1;
                              });
                            });
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

  const _TodoListItem({
    super.key,
    required this.title,
    required this.dayLabel,
    required this.timeLabel,
    required this.isDone,
    required this.onToggle,
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
        onPressed: () {
          print("menu clicked for $title");
        },
      ),
    );
  }
}
