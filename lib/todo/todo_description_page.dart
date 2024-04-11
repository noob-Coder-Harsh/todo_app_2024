import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'data_model.dart';

class TodoDescriptionPage extends StatefulWidget {
  final Todo todo;

  const TodoDescriptionPage({Key? key, required this.todo}) : super(key: key);

  @override
  _TodoDescriptionPageState createState() => _TodoDescriptionPageState();
}

class _TodoDescriptionPageState extends State<TodoDescriptionPage> {
  late TextEditingController _descriptionController;
  late FocusNode _descriptionFocusNode;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.todo.description);
    _descriptionFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: Text(
          widget.todo.title,
          style: TextStyle(color: Colors.white.withOpacity(0.75)),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          _descriptionFocusNode.unfocus();
        },
        child: SingleChildScrollView(
          child: Container(
            height: 730,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade800,
                  Colors.indigo.shade900,
                ],
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDateTimeColumn(
                      title: 'Created at',
                      date: widget.todo.createdDate,
                    ),
                    _buildDateTimeColumn(
                      title: 'Targeted Completion',
                      date: widget.todo.targetCompletionDate!,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    border: Border.all(width: 10, color: Colors.white.withOpacity(0.75)),
                  ),
                  width: double.infinity,
                  height: 200,
                  margin: EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    readOnly: true,
                    controller: _descriptionController,
                    focusNode: _descriptionFocusNode,
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'No description available',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    ),
                    expands: false,
                  ),
                ),
                const SizedBox(height: 20),
                if (widget.todo.imagePath != null && File(widget.todo.imagePath!).existsSync())
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 10, color: Colors.white.withOpacity(0.75)),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                    child: Image.file(File(widget.todo.imagePath!)),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeColumn({required String title, required DateTime date}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          DateFormat('dd/MM/yyyy').format(date),
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}
