import 'package:flutter/material.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

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
                          // For Day 1: No functionality yet
                          print("Add pressed");
                        },
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: ListView(
                    children: const [
                      _TodoListItem(
                        title: "Buy groceries",
                        dayLabel: "Today",
                        timeLabel: "6 PM",
                      ),
                      _TodoListItem(
                        title: "Finish Flutter UI",
                        dayLabel: "Today",
                        timeLabel: "8 PM",
                      ),
                      _TodoListItem(
                        title: "Read a book",
                        dayLabel: "Tomorrow",
                        timeLabel: "9 PM",
                      ),
                    ],
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

  const _TodoListItem({
    super.key,
    required this.title,
    required this.dayLabel,
    required this.timeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.check_box_outline_blank),
      title: Text(title),
      subtitle: Row(
        children: [
          Text(dayLabel),
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
