import 'dart:io';

import 'package:flutter/material.dart';
import 'package:todo_app_project/todo/todo_description_page.dart';
import 'package:todo_app_project/todo/todo_item.dart';
import 'package:todo_app_project/widgets/custom_button.dart';
import 'package:todo_app_project/widgets/image_input.dart';
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
  bool _isSearching = false;
  String _sortBy = 'None';
  String _filterBy = 'All'; // Initialize filter to 'All'
  String _searchText = '';

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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _showSortDialog,
                      icon: const Icon(Icons.sort),
                      color: Colors.white.withOpacity(0.6),
                    ),
                    const Spacer(), // Add spacer to push search icon to the right
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isSearching = !_isSearching; // Toggle search state
                          if (!_isSearching) {
                            _searchText = ''; // Clear search text when exiting search mode
                          }
                        });
                      },
                      icon: const Icon(Icons.search),
                      color: Colors.white.withOpacity(0.6),
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
                child: Row(
                  children: [
                    CustomElevatedButton(
                      onPressed: () {
                        setState(() {
                          _filterBy = 'All';
                        });
                      }, text: 'All',),
                    const SizedBox(width: 5,),
                    CustomElevatedButton(
                      onPressed: () {
                        setState(() {
                          _filterBy = 'Done';
                        });
                      }, text: 'Done',),
                    const SizedBox(width: 5,),
                    CustomElevatedButton(
                      onPressed: () {
                        setState(() {
                          _filterBy = 'Pending';
                        });
                      }, text: 'Pending',),
                  ],
                ),),
              const SizedBox(height: 50,),
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
                            // Here you can call a function to delete the todo from the database
                            _databaseHelper.deleteTodo(todo.id);
                          },
                          child: InkWell(
                            onTap: () {Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => TodoDescriptionPage(todo: todo),
                                ),
                              );
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
              ),
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
                  // Here you can call a function to delete the todo from the database
                  _databaseHelper.deleteTodo(todo.id);
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
}
