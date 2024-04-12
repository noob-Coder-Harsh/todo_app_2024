class Todo {
   String id;
   String title;
   String? description;
   DateTime createdDate;
   DateTime? targetCompletionDate;
   bool done;
   String? imagePath;
  bool isSelected; // Added variable to track selection

  Todo({
    required this.id,
    required this.title,
    this.description,
    required this.createdDate,
    this.targetCompletionDate,
    required this.done,
    this.imagePath,
    this.isSelected = false, // Initialize isSelected to false
  });

  // Inside the Todo class
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': title,
      'description': description,
      'imagePath': imagePath,
      'createdDate': createdDate.toIso8601String(),
      'targetCompletionDate': targetCompletionDate != null ? targetCompletionDate!.toIso8601String() : null,
      'done': done ? 1 : 0,
      'isSelected': isSelected ? 1 : 0, // Include isSelected in the map
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['text'],
      description: map['description'],
      imagePath: map['imagePath'],
      createdDate: DateTime.parse(map['createdDate']),
      targetCompletionDate: map['targetCompletionDate'] != null ? DateTime.parse(map['targetCompletionDate']) : null,
      done: map['done'] == 1,
      isSelected: map['isSelected'] == 1, // Assign isSelected from map
    );
  }

}
