import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:todo_app_project/todo/todo_description_page.dart';
import 'package:todo_app_project/todo/todo_item.dart';
import 'package:todo_app_project/widgets/custom_alert.dart';
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
  late Future<SharedPreferences> _prefsFuture;
  final List<Todo> _selectedTodos = [];
  bool _isSearching = false;
  String _sortBy = 'None';
  String _searchText = '';
  bool _showArchivedTodos = false;
  bool _isMultiSelecting = false;


  @override
  void initState() {
    super.initState();
    _prefsFuture = SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isMultiSelecting) {
          _resetSelectionState();
          return false;
        }
        return true;
      },
      child: Scaffold(
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
                Colors.grey.shade900,
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
                        icon: const Icon(Icons.sort,size: 32,),
                        color: Colors.white.withOpacity(0.75),
                      ),
                      const Spacer(),
                      if(_isMultiSelecting)
                      IconButton(onPressed: (){_deleteSelectedTodos();},
                          icon: const Icon(Icons.delete,color: Colors.white,)),
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
                                    return const CustomAlertDialog(actionButtonText: 'DELETE',);
                                  },
                                );
                              } else {
                                return await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const CustomAlertDialog(actionButtonText: 'ARCHIVE',);
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
                              onLongPress: (){
                                setState(() {
                                  _isMultiSelecting = !_isMultiSelecting;
                                });
                              },
                              onTap: () {Navigator.push(context, MaterialPageRoute(
                                builder: (context) => TodoDescriptionPage(todo: todo),),);
                              },
                              child: Card(
                                color: Colors.white54,
                                child: Row(
                                  children: [
                                    if(_isMultiSelecting)
                                      Checkbox(
                                        checkColor: Colors.white,
                                        activeColor: Colors.green,
                                        value: todo.isSelected,
                                        onChanged: (isChecked) {
                                          setState(() {
                                            todo.isSelected = isChecked!;
                                            if (isChecked) {
                                              _selectedTodos.add(todo);
                                            } else {
                                              _selectedTodos.remove(todo);
                                            }
                                          });
                                        },
                                      ),

                                    CheckableTodoItem(todo: todo, onChanged: _refreshTodos,),
                                    const Spacer(),
                                    IconButton(onPressed: (){_updateTodo(todo);},
                                        icon: const Icon(Icons.edit,
                                          color: Colors.white,size: 18,)
                                    )
                                  ],
                                ),
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
                                      return const CustomAlertDialog(actionButtonText: 'DELETE',);
                                    },
                                  );
                                } else {
                                  // Swipe right for unarchive
                                  return await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return const CustomAlertDialog(actionButtonText: 'UNARCHIVE',);
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
                      return const CustomAlertDialog(actionButtonText: 'DELETE',);
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
    TextEditingController textController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    File? selectedImage;
    DateTime selectedDate = DateTime.now();

    await showModalBottomSheet(
      backgroundColor: Colors.white.withOpacity(0.9),
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textController,
                    decoration: const InputDecoration(hintText: 'Enter your todo title'),
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
                        SizedBox(width: 5),
                        Text('Completion Date'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (textController.text.isNotEmpty) {
                            await _databaseHelper.insertTodo(Todo(
                              id: '', //for ID using UUID
                              title: textController.text,
                              description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                              createdDate: DateTime.now(),
                              targetCompletionDate: selectedDate,
                              done: false,
                              imagePath: selectedImage?.path, // Save image path if available
                            ));
                            _refreshTodos();
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateTodo(Todo todo) async {
    TextEditingController textController = TextEditingController(text: todo.title);
    TextEditingController descriptionController = TextEditingController(text: todo.description ?? '');
    File? selectedImage;
    DateTime? selectedDate = todo.targetCompletionDate;

    await showModalBottomSheet(
      backgroundColor: Colors.white.withOpacity(0.9),
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
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
                        SizedBox(width: 5),
                        Text('Completion Date'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (textController.text.isNotEmpty) {
                            await _databaseHelper.updateTodo(Todo(
                              id: todo.id,
                              title: textController.text,
                              description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                              createdDate: todo.createdDate,
                              targetCompletionDate: selectedDate,
                              done: todo.done,
                              imagePath: selectedImage?.path,
                            ));
                            _refreshTodos();
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('Update'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
              ListTile(title: const Text('By Name'),
                onTap: () {setState(() {_sortBy = 'By Name';});
                Navigator.of(context).pop();
                },
              ),
              ListTile(title: const Text('By Date'),
                onTap: () { setState(() {_sortBy = 'By Date';});
                Navigator.of(context).pop();
                },
              ),
              ListTile(title: const Text('By Done'),
                onTap: () { setState(() {_sortBy = 'By Done';});
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
      case 'By Name': todos.sort((a, b) => a.title.compareTo(b.title));
      break;
      case 'By Date': todos.sort((a, b) => a.targetCompletionDate!.compareTo(b.targetCompletionDate!));
      break;
      case 'By Done': todos.sort((a, b) => a.done ? -1 : 1);
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
    await _databaseHelper.deleteTodo(todoId);
    _refreshTodos();
  }

  void _archiveTodo(String todoId) async {
    final todo = await _databaseHelper.getTodoById(todoId);
    await _databaseHelper.insertArchivedTodo(todo!);
    await _databaseHelper.deleteTodo(todoId);
    _refreshTodos();
  }

  void _deleteArchivedTodo(String todoId) async {
    await _databaseHelper.deleteArchivedTodo(todoId);
    _refreshTodos();
  }

  void _unarchiveTodo(String todoId) async {
    final todo = await _databaseHelper.getArchivedTodoById(todoId);
    await _databaseHelper.insertTodo(todo!);
    await _databaseHelper.deleteArchivedTodo(todoId);
    _refreshTodos();

  }

  void _deleteSelectedTodos() {
    // Iterate through selected todos and delete them
    for (var todo in _selectedTodos) {
      _deleteTodo(todo.id);
    }
    _selectedTodos.clear();
    setState(() {
      _isMultiSelecting = false;
    });
  }

  void _resetSelectionState() {
    setState(() {
      for (var todo in _selectedTodos) {
        todo.isSelected = false;
      }
      _selectedTodos.clear();
      _isMultiSelecting = false;
    });
  }

}