import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../data_model.dart';

class TodoDescriptionPage extends StatefulWidget {
  final Todo todo;

  const TodoDescriptionPage({Key? key, required this.todo}) : super(key: key);

  @override
  State<TodoDescriptionPage> createState() => _TodoDescriptionPageState();
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
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.grey.shade900,
        title: Text(
          widget.todo.title,
          style: const TextStyle(color: Colors.white),
        ),
        elevation: 5,
        shadowColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () {
          _descriptionFocusNode.unfocus();
        },
        child: Container(
          height: size.height,
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [BoxShadow(
                            color: Colors.white,offset: Offset(0,2),
                            blurRadius: 5
                        )]
                    ),
                    child: Row(
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
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [BoxShadow(
                        color: Colors.white,offset: Offset(0,2),
                        blurRadius: 5
                      )]
                    ),
                    width: double.infinity,
                    height: size.height*0.25,
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      readOnly: true,
                      controller: _descriptionController,
                      focusNode: _descriptionFocusNode,
                      style: TextStyle(color: Colors.grey.shade900, fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: 'No description available',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      expands: false,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (widget.todo.imagePath != null && File(widget.todo.imagePath!).existsSync())
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(width: 5,color: Colors.white),
                          boxShadow: const [BoxShadow(
                              color: Colors.white,offset: Offset(0,2),
                              blurRadius: 5
                          )]
                      ),
                      child: Image.file(File(widget.todo.imagePath!)),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
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
          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          DateFormat('dd/MM/yyyy').format(date),
          style: TextStyle(color: Colors.grey.shade700,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
