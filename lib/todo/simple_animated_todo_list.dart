import 'package:flutter/material.dart';
import '../todo/todo_edit_bottom_sheet.dart';
import '../todo/todo_list_item.dart';
import '../todo/todo_item.dart';
import '../todo_detail_Screen.dart';

/// SimpleAnimatedTodoList (uses your app's TodoItem type)
/// - minimal AnimatedList wrapper
/// - parent can call addItem() on the state to insert items with animation
/// - when an item is dismissed, `onRemove` is called so the parent can persist deletion
class SimpleAnimatedTodoList extends StatefulWidget {
  /// initial items to show (optional)
  final List<TodoItem> initialItems;

  /// Called when the user deletes an item from the UI.
  /// Parent should persist the deletion if needed.
  final void Function(TodoItem item)? onRemove;

  final Future<void> Function(TodoItem item)? onToggle;

  const SimpleAnimatedTodoList({
    super.key,
    this.initialItems = const <TodoItem>[],
    this.onRemove,
    this.onToggle,
  });

  @override
  SimpleAnimatedTodoListState createState() => SimpleAnimatedTodoListState();
}

class SimpleAnimatedTodoListState extends State<SimpleAnimatedTodoList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<TodoItem> _items = [];

  @override
  void initState() {
    super.initState();
    // copy initial items
    _items.addAll(widget.initialItems);
  }

  /// Public method parent can call to add an item (animates insertion).
  /// Inserts at index 0 (top); change as needed.
  void addItem(TodoItem todo, {int index = 0}) {
    final insertIndex = index.clamp(0, _items.length);
    _items.insert(insertIndex, todo);
    _listKey.currentState?.insertItem(
      insertIndex,
      duration: const Duration(milliseconds: 260),
    );
  }

  bool removeItem(TodoItem item) {
    final index = _items.indexWhere(
      (t) => t.title == item.title && t.dueDate.isAtSameMomentAs(item.dueDate),
    );

    if (index == -1) return false;

    removeItemAt(index); // reuse your animation logic
    return true;
  }

  /// Public method to remove an item programmatically (animates removal).
  /// Returns true if removed.
  bool removeItemAt(int index) {
    if (index < 0 || index >= _items.length) return false;
    final removed = _items.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, anim) => SizeTransition(
        sizeFactor: anim,
        axis: Axis.vertical,
        child: FadeTransition(
          opacity: anim,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Card(
              elevation: 2,
              child: ListTile(title: Text(removed.title)),
            ),
          ),
        ),
      ),
      duration: const Duration(milliseconds: 300),
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      // Start with items shown immediately (no initial entrance animation).
      initialItemCount: _items.length,
      itemBuilder: (context, index, animation) {
        final todo = _items[index];
        return SizeTransition(
          sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          axis: Axis.vertical,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Dismissible(
              key: ValueKey(
                '${todo.title}_${todo.dueDate.toIso8601String()}_$index',
              ),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) {
                // Remove from internal list and animate out (use removeItemAt so animation matches)
                final existsIndex = _items.indexWhere(
                  (e) => e.hashCode == todo.hashCode,
                );
                if (existsIndex == -1) return;
                final removed = _items.removeAt(existsIndex);
                _listKey.currentState?.removeItem(
                  existsIndex,
                  (context, anim) => SizeTransition(
                    sizeFactor: anim,
                    axis: Axis.vertical,
                    child: FadeTransition(
                      opacity: anim,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Card(
                          elevation: 2,
                          child: ListTile(title: Text(removed.title)),
                        ),
                      ),
                    ),
                  ),
                );

                // notify parent so it can persist deletion
                widget.onRemove?.call(removed);
              },
              child: TodoListItem(
                title: todo.title,
                dueDate: todo.dueDate,
                isDone: todo.isDone,
                onEdit: () => showEditTodoBottomSheet(context, todo),
                onToggle: () async {
                  await widget.onToggle!(todo);
                },
                onTap: () async {
                  final TodoItem? removed = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TodoDetailScreen(todo: todo),
                    ),
                  );
                  if (removed != null) {
                    widget.onRemove?.call(removed);
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
