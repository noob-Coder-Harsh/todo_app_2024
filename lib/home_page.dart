import 'package:flutter/material.dart';
import 'package:todo_app_project/todo/todo_item.dart';
import 'package:todo_app_project/widgets/category_buttons.dart';

import 'widgets/appbar.dart';
import 'widgets/custom_button.dart';
import 'widgets/date.dart';
import 'todo/data_model.dart';
import 'todo/database_helper.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _databaseHelper = DatabaseHelper();

  Future<void> _refreshTodos() async {
    setState(() {});
  }

  Future<void> _addTodo() async {
    await showDialog(
      context: context,
      builder: (context) {
        TextEditingController textController = TextEditingController();
        return AlertDialog(
          title: const Text('Add Todo'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: 'Enter your todo'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (textController.text.isNotEmpty) {
                  await _databaseHelper.insertTodo(Todo(
                    id: 0, // This will be ignored by SQLite
                    text: textController.text,
                    done: false,
                  ));
                  _refreshTodos();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        child: const Icon(Icons.add),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade800,
              Colors.indigo.shade900,
              // Theme.of(context).colorScheme.primary,
              // Theme.of(context).colorScheme.primary.withAlpha(99),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 32.0,left: 16,right: 16),
          child: Column(
            children: [
              const Appbar(),
              const DateWidget(),
              const SizedBox(height: 20,),
              Row(
                children: [
                  Text('Categories', style: TextStyle(color: Colors.white.withOpacity(0.75)),),
                  const SizedBox(width: 5,),
                  Icon(Icons.draw,color: Colors.white.withOpacity(0.75),size: 16,)
                ],
              ),
              const SizedBox(height: 10,),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: CategoryButtons()),
              const SizedBox(height: 50,),
              Row(children: [
                Text('your Todo Items', style: TextStyle(color: Colors.white.withOpacity(0.75)),),
                const SizedBox(width: 5,),
                Icon(Icons.task_alt, color: Colors.white.withOpacity(0.75), size: 16,)
              ],),

              Expanded(
                child: FutureBuilder<List<Todo>>(
                  future: _databaseHelper.getTodos(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    final todos = snapshot.data ?? [];
                    return ListView.builder(
                      itemCount: todos.length,
                      itemBuilder: (context, index) {
                        final todo = todos[index];
                        return CheckableTodoItem(
                          todo: todo,
                          onChanged: _refreshTodos,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
