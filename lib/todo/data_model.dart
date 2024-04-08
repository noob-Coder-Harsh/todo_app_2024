class Todo {
  int id;
  String text;
  bool done;

  Todo({
    required this.id,
    required this.text,
    required this.done,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'done': done ? 1 : 0, // SQLite does not support boolean, so we store 1 for true and 0 for false
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      text: map['text'],
      done: map['done'] == 1, // Convert 1 to true, 0 to false
    );
  }
}
