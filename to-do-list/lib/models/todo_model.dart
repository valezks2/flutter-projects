import 'dart:convert';

class Todo {
  final String id;

  final String title;

  bool isDone;

  Todo({required this.id, required this.title, this.isDone = false});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'isDone': isDone};
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] ?? '',

      title: map['title'] ?? '',

      isDone: map['isDone'] ?? false,
    );
  }

  static String encode(List<Todo> todos) => json.encode(
    todos.map<Map<String, dynamic>>((todo) => todo.toMap()).toList(),
  );

  static List<Todo> decode(String todosJson) =>
      (json.decode(todosJson) as List<dynamic>)
          .map<Todo>((item) => Todo.fromMap(item))
          .toList();
}
