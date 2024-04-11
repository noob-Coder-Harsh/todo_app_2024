import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data_model.dart';

class CheckableTodoItem extends StatelessWidget {
  const CheckableTodoItem({
    Key? key,
    required this.todo,
    required this.onChanged,
  }) : super(key: key);

  final Todo todo;
  final Function(bool?) onChanged;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        final SharedPreferences prefs = snapshot.data!;
        final bool done = prefs.getBool('todo_${todo.id}') ?? false;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Card(
            color: Colors.white.withOpacity(0.6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  checkColor: Colors.black, // Color of the check mark
                  activeColor: Colors.green, // Color when checked
                  value: done, // Use done property
                  onChanged: onChanged,
                ),
                const SizedBox(width: 6),
                Text(todo.title, style: TextStyle(color: Colors.black.withOpacity(0.75), fontSize: 20)),
              ],
            ),
          ),
        );
      },
    );
  }
}
