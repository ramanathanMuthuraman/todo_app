import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'todo_item.dart';

enum FilterType { all, pending, completed }

class TodoController extends ChangeNotifier {
  static const _storageKey = 'todos_v1';

  final List<TodoItem> _todos = [];
  List<TodoItem> _visibleTodos = [];

  String _searchQuery = "";
  FilterType _filter = FilterType.all;

  List<TodoItem> get todos => List.unmodifiable(_todos);
  List<TodoItem> get visibleTodos => List.unmodifiable(_visibleTodos);
  FilterType get filter => _filter;

  // -------------------------------
  // Load all todos on startup
  // -------------------------------
  Future<void> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data == null) return;

    final decoded = jsonDecode(data) as List;

    _todos
      ..clear()
      ..addAll(decoded.map((m) => TodoItem.fromMap(m)));

    _sort();
    _applyFilters();
  }

  Future<void> clearAll() async {
    _todos.clear();
    _applyFilters(); // will call notifyListeners()
    await saveTodos(); // persist the empty list
  }

  // Save all todos
  Future<void> saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_todos.map((t) => t.toMap()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  // Add a new todo
  Future<void> addTodo(String title) async {
    _todos.add(TodoItem(title: title, dueDate: DateTime.now()));
    _sort();
    _applyFilters();
    await saveTodos();
  }

  // Toggle a todo
  Future<void> toggleTodo(TodoItem item) async {
    item.isDone = !item.isDone;
    _sort();
    _applyFilters();
    await saveTodos();
  }

  // Edit a todo
  Future<void> updateTodo(TodoItem item, String title, DateTime dueDate) async {
    item.title = title;
    item.dueDate = dueDate;
    _sort();
    _applyFilters();
    await saveTodos();
  }

  // Delete a todo
  Future<void> deleteAt(int index) async {
    _todos.removeAt(index);
    _applyFilters();
    await saveTodos();
  }

  // Filters
  void setFilter(FilterType type) {
    _filter = type;
    _applyFilters();
  }

  void setSearch(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applyFilters();
  }

  // Apply filtering + search
  void _applyFilters() {
    _visibleTodos = _todos.where((item) {
      final matchSearch = item.title.toLowerCase().contains(_searchQuery);

      final matchFilter =
          _filter == FilterType.all ||
          (_filter == FilterType.pending && !item.isDone) ||
          (_filter == FilterType.completed && item.isDone);

      return matchSearch && matchFilter;
    }).toList();

    notifyListeners();
  }

  // Sorting: pending first, then due date
  void _sort() {
    _todos.sort((a, b) {
      if (a.isDone != b.isDone) {
        return a.isDone ? 1 : -1;
      }
      return a.dueDate.compareTo(b.dueDate);
    });
  }
}

class TodoControllerProvider extends InheritedNotifier<TodoController> {
  const TodoControllerProvider({
    super.key,
    required super.child,
    required TodoController controller,
  }) : super(notifier: controller);

  static TodoController of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<TodoControllerProvider>();
    assert(provider != null, 'No TodoControllerProvider found in context');
    return provider!.notifier!;
  }
}
