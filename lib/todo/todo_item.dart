class TodoItem {
  String title;
  DateTime dueDate;
  bool isDone;

  TodoItem({required this.title, required this.dueDate, this.isDone = false});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'isDone': isDone,
    };
  }

  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      title: map['title'],
      dueDate: DateTime.parse(map['dueDate']),
      isDone: map['isDone'],
    );
  }
}
