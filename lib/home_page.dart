import 'dart:io';

import 'package:flutter/material.dart';
import 'package:todo_app_project/todo/todo_description_page.dart';
import 'package:todo_app_project/widgets/custom_button.dart';
import 'package:todo_app_project/widgets/image_input.dart';
import 'widgets/date.dart';
import 'todo/data_model.dart';
import 'todo/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _databaseHelper = DatabaseHelper();
  bool _isSearching = false;
  String _sortBy = 'None';
  String _filterBy = 'All'; // Initialize filter to 'All'
  String _searchText = '';
  late Future<SharedPreferences> _prefsFuture;
  bool _showArchivedTodos = false; // Add this line in your state class

  @override
  void initState() {
    super.initState();
    _prefsFuture = SharedPreferences.getInstance();
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
              Colors.indigo,
              Colors.indigo.shade900,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 32.0, left: 16, right: 16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _showSortDialog,
                      icon: const Icon(Icons.sort,size: 32,),
                      color: Colors.white.withOpacity(0.75),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isSearching = !_isSearching;
                          if (!_isSearching) {
                            _searchText = '';
                          }
                        });
                      },
                      icon: const Icon(Icons.search,size: 32,),
                      color: Colors.white.withOpacity(0.75),
                    ),
                    if (_isSearching)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextField(
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Search',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(8.0),
                            ),
                            onChanged: _handleSearch,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const DateWidget(),
              const SizedBox(
                height: 20,
              ),
              const SizedBox(
                height: 50,
              ),
              Row(
                children: [
                  Text(
                    'your Todo Items',
                    style: TextStyle(color: Colors.white.withOpacity(0.75)),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Icon(
                    Icons.task_alt,
                    color: Colors.white.withOpacity(0.75),
                    size: 16,
                  )
                ],
              ),
              _isSearching
                  ? _buildSearchResults()
                  : Expanded(
                      child: FutureBuilder<List<Todo>>(
                        future: _databaseHelper.getTodos(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }

                          final todos = snapshot.data ?? [];
                          final sortedTodos = _sortTodos(todos);

                          return ListView.builder(
                            itemCount: sortedTodos.length,
                            itemBuilder: (context, index) {
                              final todo = sortedTodos[index];

                              return Dismissible(
                                key: Key(todo.id),
                                background: Container(
                                  margin: const EdgeInsets.all(8),
                                  alignment: Alignment.centerLeft,
                                  color: Colors.red.withOpacity(
                                      0.75), // Swipe left for delete
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                secondaryBackground: Container(
                                  margin: const EdgeInsets.all(8),
                                  alignment: Alignment.centerRight,
                                  color: Colors.green.withOpacity(
                                      0.75), // Swipe right for archive
                                  child: const Icon(
                                    Icons.archive,
                                    color: Colors.white,
                                  ),
                                ),
                                direction: DismissDirection
                                    .horizontal, // Allow horizontal swiping
                                confirmDismiss: (direction) async {
                                  if (direction ==
                                      DismissDirection.startToEnd) {
                                    // Swipe left for delete
                                    return await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Confirm"),
                                          content: const Text(
                                              "Are you sure you want to delete this todo?"),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text("CANCEL"),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: const Text("DELETE"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    // Swipe right for archive
                                    return await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Confirm"),
                                          content: const Text(
                                              "Are you sure you want to archive this todo?"),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text("CANCEL"),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: const Text("ARCHIVE"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                onDismissed: (direction) {
                                  if (direction ==
                                      DismissDirection.startToEnd) {
                                    // Swipe left for delete
                                    _deleteTodo(todo.id);
                                  } else {
                                    // Swipe right for archive
                                    _archiveTodo(todo.id);
                                  }
                                },
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TodoDescriptionPage(todo: todo),
                                      ),
                                    );
                                  },
                                  child: FutureBuilder<SharedPreferences>(
                                    future: _prefsFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      }
                                      final SharedPreferences prefs =
                                          snapshot.data!;
                                      final bool done =
                                          prefs.getBool('todo_${todo.id}') ??
                                              false;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Card(
                                          color: Colors.white.withOpacity(0.6),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Checkbox(
                                                checkColor: Colors.white,
                                                activeColor: Colors.green,
                                                splashRadius: 16.0,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16)),
                                                value: done,
                                                onChanged: (isChecked) {
                                                  _setDone(todo.id, isChecked);
                                                },
                                              ),
                                              const SizedBox(width: 6),
                                              Text(todo.title,
                                                  style: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(0.75),
                                                      fontSize: 20)),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _showArchivedTodos =
                          !_showArchivedTodos; // Toggle visibility of archived todos
                    });
                  },
                  child: Row(
                    children: [
                      Text('Archived Todos',
                          style:
                              TextStyle(color: Colors.white.withOpacity(0.75))),
                      Icon(
                        _showArchivedTodos
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        color: Colors.white.withOpacity(0.75),
                      ),
                    ],
                  ),
                ),
              ),
              // Space to display archived todos
              if (_showArchivedTodos) ...[
                // Show archived todos only if the toggle is enabled
                AnimatedSwitcher(
                  duration: const Duration(seconds: 2),
                  child: FutureBuilder<List<Todo>>(
                    future: _databaseHelper.getArchivedTodos(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      final archivedTodos = snapshot.data ?? [];
                      if (archivedTodos.isEmpty) {
                        return const Text('No archived todos.');
                      }
                      return ListView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        // Disable scrolling to ensure it doesn't interfere with the outer ListView
                        children: archivedTodos.map((todo) {
                          return Dismissible(
                            key: Key(todo.id),
                            background: Container(
                              margin: const EdgeInsets.all(8),
                              alignment: Alignment.centerLeft,
                              color: Colors.red
                                  .withOpacity(0.75), // Swipe left for delete
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            secondaryBackground: Container(
                              margin: const EdgeInsets.all(8),
                              alignment: Alignment.centerRight,
                              color: Colors.green
                                  .withOpacity(0.75), // Swipe right for unarchive
                              child: const Icon(
                                Icons.unarchive,
                                color: Colors.white,
                              ),
                            ),
                            direction: DismissDirection
                                .horizontal, // Allow horizontal swiping
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.startToEnd) {
                                // Swipe left for delete
                                return await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Confirm"),
                                      content: const Text(
                                          "Are you sure you want to delete this todo?"),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text("CANCEL"),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text("DELETE"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                // Swipe right for unarchive
                                return await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Confirm"),
                                      content: const Text(
                                          "Are you sure you want to unarchive this todo?"),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text("CANCEL"),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text("UNARCHIVE"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            onDismissed: (direction) {
                              if (direction == DismissDirection.startToEnd) {
                                // Swipe left for delete
                                _deleteArchivedTodo(todo.id);
                              } else {
                                // Swipe right for unarchive
                                _unarchiveTodo(todo.id);
                              }
                            },
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TodoDescriptionPage(todo: todo),
                                  ),
                                );
                              },
                              child: Padding(

                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: FutureBuilder<SharedPreferences>(
                                  future: _prefsFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    }
                                    final SharedPreferences prefs =
                                    snapshot.data!;
                                    final bool done =
                                        prefs.getBool('todo_${todo.id}') ??
                                            false;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Card(
                                        color: Colors.white.withOpacity(0.6),
                                        child: Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: [
                                            Checkbox(
                                              checkColor: Colors.white,
                                              activeColor: Colors.green,
                                              splashRadius: 16.0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      16)),
                                              value: done,
                                              onChanged: (isChecked) {
                                                _setDone(todo.id, isChecked);
                                              },
                                            ),
                                            const SizedBox(width: 6),
                                            Text(todo.title,
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.75),
                                                    fontSize: 20)),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Expanded(
      child: FutureBuilder<List<Todo>>(
        future: _showArchivedTodos
            ? _databaseHelper.getArchivedTodos()
            : _databaseHelper.getTodos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          final todos = snapshot.data ?? [];
          final sortedTodos = _sortTodos(todos);

          return ListView.builder(
            itemCount: sortedTodos.length,
            itemBuilder: (context, index) {
              final todo = sortedTodos[index];
              return Dismissible(
                key: Key(todo.id),
                background: Container(
                  margin: const EdgeInsets.all(8),
                  alignment: Alignment.centerLeft,
                  color: Colors.red.withOpacity(0.75), // Swipe left for delete
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                secondaryBackground: Container(
                  margin: const EdgeInsets.all(8),
                  alignment: Alignment.centerRight,
                  color: _showArchivedTodos
                      ? Colors.blue.withOpacity(0.75)
                      : Colors.green.withOpacity(
                          0.75), // Swipe right for archive if showing archived todos, otherwise swipe right to add back to main todo list
                  child: _showArchivedTodos
                      ? const Icon(
                          Icons.unarchive,
                          color: Colors.white,
                        )
                      : const Icon(
                          Icons.archive,
                          color: Colors.white,
                        ),
                ),
                direction:
                    DismissDirection.horizontal, // Allow horizontal swiping
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    // Swipe left for delete
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Confirm"),
                          content: const Text(
                              "Are you sure you want to delete this todo?"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("CANCEL"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("DELETE"),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    // Swipe right for archive or add back to main todo list
                    return true;
                  }
                },
                onDismissed: (direction) {
                  if (direction == DismissDirection.startToEnd) {
                    // Swipe left for delete
                    _deleteTodo(todo.id);
                  } else {
                    // Swipe right for archive or add back to main todo list
                    if (_showArchivedTodos) {
                      // If showing archived todos, add back to main todo list
                      _addBackToTodos(todo.id);
                    } else {
                      // If not showing archived todos, archive the todo
                      _archiveTodo(todo.id);
                    }
                  }
                },
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TodoDescriptionPage(todo: todo),
                      ),
                    );
                  },
                  child: FutureBuilder<SharedPreferences>(
                    future: _prefsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      final SharedPreferences prefs = snapshot.data!;
                      final bool done =
                          prefs.getBool('todo_${todo.id}') ?? false;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Card(
                          color: Colors.white.withOpacity(0.6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                checkColor: Colors.white,
                                activeColor: Colors.green,
                                splashRadius: 16.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                value: done,
                                onChanged: (isChecked) {
                                  _setDone(todo.id, isChecked);
                                },
                              ),
                              const SizedBox(width: 6),
                              Text(todo.title,
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.75),
                                      fontSize: 20)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _addBackToTodos(String todoId) async {
    // Retrieve the todo item from the 'archived_todos' table
    final todo = await _databaseHelper.getArchivedTodoById(todoId);

    // Insert the todo item into the 'todos' table
    await _databaseHelper.insertTodo(todo!);

    // Delete the todo item from the 'archived_todos' table
    await _databaseHelper.deleteArchivedTodo(todoId);

    // Refresh the UI to reflect the changes
    _refreshTodos();
  }

  void _setDone(String todoId, bool? isChecked) async {
    if (isChecked != null) {
      final SharedPreferences prefs = await _prefsFuture;
      setState(() {
        prefs.setBool('todo_$todoId', isChecked);
      });
    }
  }

  Future<void> _addTodo() async {
    await showDialog(
      context: context,
      builder: (context) {
        TextEditingController textController = TextEditingController();
        TextEditingController descriptionController = TextEditingController();
        File? selectedImage;
        DateTime selectedDate = DateTime.now();

        return AlertDialog(
          title: const Text('Add Todo'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textController,
                  decoration:
                      const InputDecoration(hintText: 'Enter your todo'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                      hintText: 'Enter description (optional)'),
                ),
                const SizedBox(height: 8),
                ImageInput(
                  onPickImage: (image) {
                    selectedImage = image;
                  },
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null && pickedDate != selectedDate) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_month),
                      SizedBox(
                        width: 5,
                      ),
                      Text('Completion Date'),
                    ],
                  ),
                ),
              ],
            ),
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
                    id: '',
                    title: textController.text,
                    description: descriptionController.text.isNotEmpty
                        ? descriptionController.text
                        : null,
                    createdDate: DateTime.now(),
                    targetCompletionDate: selectedDate,
                    done: false,
                    imagePath:
                        selectedImage != null ? selectedImage!.path : null,
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

  Future<void> _showSortDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sort By'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Name'),
                onTap: () {
                  setState(() {
                    _sortBy = 'Name';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Date'),
                onTap: () {
                  setState(() {
                    _sortBy = 'Date';
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<Todo> _sortTodos(List<Todo> todos) {
    switch (_sortBy) {
      case 'Name':
        todos.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Date':
        todos.sort((a, b) =>
            a.targetCompletionDate!.compareTo(b.targetCompletionDate!));
        break;
      default:
        break;
    }
    return todos;
  }

  void _handleSearch(String value) {
    setState(() {
      _searchText = value;
    });
  }

  Future<void> _refreshTodos() async {
    setState(() {});
  }

  void _deleteTodo(String todoId) async {
    // Perform actions to delete the todo item
    await _databaseHelper.deleteTodo(todoId);

    // Refresh the UI to reflect the changes
    _refreshTodos();
  }

  void _archiveTodo(String todoId) async {
    // Retrieve the todo item from the 'todos' table
    final todo = await _databaseHelper.getTodoById(todoId);

    // Insert the todo item into the 'archived_todos' table
    await _databaseHelper.insertArchivedTodo(todo!);

    // Delete the todo item from the 'todos' table
    await _databaseHelper.deleteTodo(todoId);

    // Refresh the UI to reflect the changes
    _refreshTodos();
  }

  void _deleteArchivedTodo(String todoId) async {
    // Perform actions to delete the archived todo item
    await _databaseHelper.deleteArchivedTodo(todoId);

    // Refresh the UI to reflect the changes
    _refreshTodos();
  }

  void _unarchiveTodo(String todoId) async {
    // Retrieve the archived todo item from the 'archived_todos' table
    final todo = await _databaseHelper.getArchivedTodoById(todoId);

    // Insert the archived todo item back into the 'todos' table
    await _databaseHelper.insertTodo(todo!);

    // Delete the archived todo item from the 'archived_todos' table
    await _databaseHelper.deleteArchivedTodo(todoId);

    // Refresh the UI to reflect the changes
    _refreshTodos();
  }
}
