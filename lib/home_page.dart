import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:todo_app_project/todo/todo_description_page.dart';
import 'package:todo_app_project/todo/todo_item.dart';
import 'package:todo_app_project/widgets/image_input.dart';
import 'data_model.dart';
import 'database_helper.dart';
import 'widgets/date.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final _databaseHelper = DatabaseHelper();
  bool _isSearching = false;
  String _sortBy = 'None';
  String _searchText = '';
  late Future<SharedPreferences> _prefsFuture;
  bool _showArchivedTodos = false;

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
              Colors.indigo.shade600,
              Colors.indigo.shade900,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 32.0,left: 16,right: 16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: [
                    IconButton(onPressed:() {setState(() {
                          _showSortDialog();
                          _showArchivedTodos = false;
                        });
                      },
                      icon: const Icon(Icons.sort,size: 32),
                      color: Colors.white.withOpacity(0.75),
                    ),
                    const Spacer(),
                    IconButton(onPressed: () {setState(() {
                          _isSearching = !_isSearching; // Toggle search state
                          _showArchivedTodos = false;
                          if (!_isSearching) {
                            _searchText = ''; // Clear search text when exiting search mode
                          }});
                      },
                      icon: const Icon(Icons.search,size: 32,),
                      color: Colors.white.withOpacity(0.75),
                    ),
                    if (_isSearching)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextField(autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Search',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide.none,),
                              contentPadding: const EdgeInsets.all(8.0),),
                            onChanged: _handleSearch,),
                        ),
                      ),
                  ],
                ),
              ),
              const DateWidget(),
              const SizedBox(height: 40,),
              Row(children: [
                Text('your Todo Items', style: TextStyle(color: Colors.white.withOpacity(0.75)),),
                const SizedBox(width: 5,),
                Icon(Icons.task_alt, color: Colors.white.withOpacity(0.75), size: 16,)
              ],),
              _isSearching ? _buildSearchResults() :
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
                    final sortedTodos = _sortTodos(todos); // Sort todos
                    return ListView.builder(
                      itemCount: sortedTodos.length,
                      itemBuilder: (context, index) {
                        final todo = sortedTodos[index];
                        return Dismissible(
                          key: Key(todo.id), // Unique key for each todo item
                          background: Container(
                            margin: const EdgeInsets.all(8), alignment: Alignment.centerLeft, color: Colors.red.withOpacity(0.75),
                            child: const Icon(Icons.delete, color: Colors.white,),
                          ),
                          secondaryBackground: Container(
                            margin: const EdgeInsets.all(8),
                            alignment: Alignment.centerRight,
                            color: Colors.green.withOpacity(0.75),
                            child: const Icon(Icons.archive,
                              color: Colors.white,),
                          ),
                          direction: DismissDirection.horizontal,
                          confirmDismiss: (direction) async {
                            if (direction ==
                                DismissDirection.startToEnd) {
                              return await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Confirm"),
                                    content: const Text(
                                        "Are you sure you want to delete this todo?"),
                                    actions: <Widget>[
                                      TextButton(onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text("CANCEL"),
                                      ),
                                      TextButton(onPressed: () => Navigator.of(context).pop(true),
                                        child: const Text("DELETE"),),
                                    ],
                                  );
                                },
                              );
                            } else {
                              return await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Confirm"),
                                    content: const Text(
                                        "Are you sure you want to archive this todo?"),
                                    actions: <Widget>[
                                      TextButton(onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text("CANCEL"),),
                                      TextButton(onPressed: () => Navigator.of(context).pop(true),
                                        child: const Text("ARCHIVE"),),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          onDismissed: (direction) {
                            if (direction == DismissDirection.startToEnd) {
                              _deleteTodo(todo.id);
                            } else {
                              _archiveTodo(todo.id);
                            }},
                          child: InkWell(
                            onTap: () {Navigator.push(context, MaterialPageRoute(
                              builder: (context) => TodoDescriptionPage(todo: todo),),);
                            },
                            child: CheckableTodoItem(todo: todo, onChanged: _refreshTodos,),
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
                      Text('Archived Todos', style: TextStyle(color: Colors.white.withOpacity(0.75))),
                      Icon(_showArchivedTodos
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        color: Colors.white.withOpacity(0.75),
                      ),
                    ],
                  ),
                ),
              ),
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
                        physics: const NeverScrollableScrollPhysics(),
                        children: archivedTodos.map((todo) {
                          return Dismissible(
                            key: Key(todo.id),
                            background: Container(
                              margin: const EdgeInsets.all(8),
                              alignment: Alignment.centerLeft,
                              color: Colors.red.withOpacity(0.75),
                              child: const Icon(Icons.delete,
                                color: Colors.white,),
                            ),
                            secondaryBackground: Container(
                              margin: const EdgeInsets.all(8),
                              alignment: Alignment.centerRight,
                              color: Colors.green.withOpacity(0.75),
                              child: const Icon(Icons.unarchive,
                                color: Colors.white,),
                            ),
                            direction: DismissDirection.horizontal,
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.startToEnd) {
                                return await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Confirm"),
                                      content: const Text(
                                          "Are you sure you want to delete this todo?"),
                                      actions: <Widget>[
                                        TextButton(onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text("CANCEL"),),
                                        TextButton(onPressed: () =>Navigator.of(context).pop(true),
                                          child: const Text("DELETE"),),
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
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: CheckableTodoItem(todo: todo, onChanged: _refreshTodos,)
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
        future: _databaseHelper.getTodos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          final todos = snapshot.data ?? [];
          final filteredTodos = todos.where((todo) =>
          todo.title.toLowerCase().contains(_searchText.toLowerCase()) ||
              (todo.description?.toLowerCase().contains(_searchText.toLowerCase()) ?? false)
          ).toList();
          return ListView.builder(
            itemCount: filteredTodos.length,
            itemBuilder: (context, index) {
              final todo = filteredTodos[index];
              return Dismissible(
                key: Key(todo.id), // Unique key for each todo item
                background: Container(
                  margin: const EdgeInsets.all(8),
                  alignment: Alignment.centerRight,
                  color: Colors.red.withOpacity(0.75),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  // Confirmation dialog to ensure the user wants to delete
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Confirm"),
                        content: const Text("Are you sure you want to delete this todo?"),
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
                },
                onDismissed: (direction) {
                  // Remove the item from the data source
                  _databaseHelper.deleteTodo(todo.id);
                },
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TodoDescriptionPage(todo: todo),),);
                  },
                  child: CheckableTodoItem(
                    todo: todo,
                    onChanged: _refreshTodos,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _addTodo() async {
    await showDialog(
      context: context,
      builder: (context) {
        TextEditingController textController = TextEditingController();
        TextEditingController descriptionController = TextEditingController();
        File? selectedImage; // Track selected image
        DateTime selectedDate = DateTime.now();
        return AlertDialog(
          title: const Text('Add Todo'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(hintText: 'Enter your todo'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(hintText: 'Enter description (optional)'),
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
                      SizedBox(width: 5,),
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
                    id: '', // This will be ignored by SQLite
                    title: textController.text,
                    description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                    createdDate: DateTime.now(),
                    targetCompletionDate: selectedDate,
                    done: false,
                    imagePath: selectedImage != null ? selectedImage!.path : null, // Save image path if available
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
        todos.sort((a, b) => a.targetCompletionDate!.compareTo(b.targetCompletionDate!));
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