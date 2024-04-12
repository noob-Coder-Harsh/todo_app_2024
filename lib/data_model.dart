class Todo {
  String id; // Include the id variable
  String title;
  String? description;
  String? imagePath;
  DateTime createdDate;
  DateTime? targetCompletionDate;
  bool done;

  Todo({
    required this.id, // Make id required in the constructor
    required this.title,
    this.description,
    this.imagePath,
    required this.createdDate,
    this.targetCompletionDate,
    required this.done,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id, // Include id in the map
      'text': title,
      'description': description,
      'imagePath': imagePath,
      'createdDate': createdDate.toIso8601String(),
      'targetCompletionDate': targetCompletionDate != null ? targetCompletionDate!.toIso8601String() : null,
      'done': done ? 1 : 0,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'], // Assign id from map
      title: map['text'],
      description: map['description'],
      imagePath: map['imagePath'],
      createdDate: DateTime.parse(map['createdDate']),
      targetCompletionDate: map['targetCompletionDate'] != null ? DateTime.parse(map['targetCompletionDate']) : null,
      done: map['done'] == 1,
    );
  }
}
