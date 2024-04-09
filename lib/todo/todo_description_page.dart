import 'dart:io';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'data_model.dart';

class TodoDescriptionPage extends StatelessWidget {
  final Todo todo;

  const TodoDescriptionPage({Key? key, required this.todo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: Text(
          todo.title,
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
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
        child: Column(
          children: [
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Created at',
                        style: TextStyle(color: Colors.white.withOpacity(0.8),fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5), // Add space between text and date
                    Text(
                      DateFormat('dd/MM/yyyy')
                          .format(todo.createdDate), // Format the date
                      style: TextStyle(color: Colors.white.withOpacity(0.8),fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Targeted Completion',
                        style: TextStyle(color: Colors.white.withOpacity(0.8),fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5), // Add space between text and date
                    Text(
                      DateFormat('dd/MM/yyyy')
                          .format(todo.targetCompletionDate!), // Format the date
                      style: TextStyle(color: Colors.white.withOpacity(0.8),fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                todo.description ?? 'No description available',
                style: TextStyle(color: Colors.white.withOpacity(0.9),fontSize: 16),
              ),
            ),
            const SizedBox(height: 20,),
            // Display existing image if available
            if (todo.imagePath != null &&
                File(todo.imagePath!).existsSync()) // Check if file exists
              Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 10, color: Colors.white.withOpacity(0.75))),
                margin: const EdgeInsets.all(32.0),
                child: Image(
                  image: FileImage(File(todo.imagePath!)),
                ),
              ),
            // Display created date
          ],
        ),
      ),
    );
  }
}
