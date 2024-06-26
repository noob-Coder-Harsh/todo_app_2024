import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data_model.dart';

class CheckableTodoItem extends StatefulWidget {
  const CheckableTodoItem({
    Key? key,
    required this.todo,
    required this.onChanged,
  }) : super(key: key);

  final Todo todo;
  final VoidCallback onChanged;

  @override
  State<CheckableTodoItem> createState() => _CheckableTodoItemState();
}

class _CheckableTodoItemState extends State<CheckableTodoItem> {
  late Future<SharedPreferences> _prefsFuture;

  @override
  void initState() {
    super.initState();
    _prefsFuture = SharedPreferences.getInstance();
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: _prefsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        final SharedPreferences prefs = snapshot.data!;
        final bool done = prefs.getBool('todo_${widget.todo.id}') ?? false;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                checkColor: Colors.white,
                activeColor: Colors.green,
                splashRadius: 16.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                value: done,
                onChanged: (newValue) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Update Task"),
                        content: const Text("Do you want to update this task"),
                        actions: <Widget>[
                          TextButton(
                            child: const Text("No"),
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                              _setDone(false); // Mark task as not done
                            },
                          ),
                          TextButton(
                            child: const Text("Yes"),
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                              _setDone(true); // Mark task as done
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),

              const SizedBox(width: 6),
              Text(
                widget.todo.title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 20,
                ),
              ),

            ],
          ),
        );
      },
    );
  }

  void _setDone(bool? isChecked) async {
    if (isChecked != null) {
      final SharedPreferences prefs = await _prefsFuture;
      setState(() {
        widget.todo.done = isChecked;
      });
      await prefs.setBool('todo_${widget.todo.id}', isChecked);
      widget.onChanged();
    }
  }
}

