import 'package:flutter/material.dart';
import 'dart:async';
import 'theme_controller.dart';
import 'todo/todo_controller.dart';
import 'todo/filter_button.dart';
import 'settings_screen.dart';
// import 'todo_detail_screen.dart';
import 'todo/simple_animated_todo_list.dart';
import 'todo/todo_item.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _taskController = TextEditingController();

  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  @override
  void dispose() {
    _taskController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todos = TodoControllerProvider.of(context); // 👈 get controller
    final list = todos.visibleTodos; // 👈 use controller data
    final theme = ThemeControllerProvider.of(context);
    final simpleListKey = GlobalKey<SimpleAnimatedTodoListState>();
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
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
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

                      await todos.addTodo(text); // 👈 use controller
                      simpleListKey.currentState?.addItem(
                        TodoItem(
                          title: text,
                          dueDate: DateTime.now(),
                          isDone: false,
                        ),
                      );
                      _taskController.clear();
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
                onChanged: (value) {
                  _searchDebounce?.cancel();
                  _searchDebounce = Timer(
                    const Duration(milliseconds: 250),
                    () {
                      todos.setSearch(value);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // 3) Filter buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilterButton(label: "All", type: FilterType.all),
                SizedBox(width: 8),
                FilterButton(label: "Pending", type: FilterType.pending),
                SizedBox(width: 8),
                FilterButton(label: "Completed", type: FilterType.completed),
              ],
            ),

            const SizedBox(height: 12),

            // 4) List / Empty state — must be Expanded
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                // use a custom transition: fade + slide
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final inAnim = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  );
                  final offsetAnim = Tween<Offset>(
                    begin: const Offset(0.0, 0.08), // slight slide up on enter
                    end: Offset.zero,
                  ).animate(inAnim);

                  return FadeTransition(
                    opacity: inAnim,
                    child: SlideTransition(position: offsetAnim, child: child),
                  );
                },

                child: list.isEmpty
                    ? Center(
                        key: ValueKey(
                          'empty_${todos.filter}_${_searchController.text.trim()}',
                        ),
                        child: Text(
                          (todos.todos.isEmpty &&
                                  _searchController.text.trim().isEmpty &&
                                  todos.filter == FilterType.all)
                              ? 'No tasks yet. Add your first one above!'
                              : 'No tasks match your search/filter.',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : Container(
                        // Give list its own key derived from filter + query + length to trigger switch
                        key: ValueKey(
                          'list_${todos.filter}_${_searchController.text.trim()}',
                        ),
                        child: SimpleAnimatedTodoList(
                          key: simpleListKey,
                          initialItems: todos.visibleTodos,

                          onRemove: (removed) async {
                            // persist deletion using your controller
                            // find index in controller's visibleTodos if you need it, or call a delete by title/dueDate
                            await todos.deleteByTitleAndDate(
                              removed.title,
                              removed.dueDate,
                            ); // example — adapt to your API
                            simpleListKey.currentState?.removeItem(removed);
                          },
                          onToggle: (todo) async {
                            // best if your controller has a toggle method that persists
                            await todos.toggleTodo(
                              todo,
                            ); // implement this in controller if missing
                          },
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
