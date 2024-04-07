import 'package:flutter/material.dart';
import 'package:todo_app_project/widgets/custom_button.dart';

import 'widgets/appbar.dart';
import 'widgets/date.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade700,
                Colors.blue.shade900,
                // Theme.of(context).colorScheme.primary,
                // Theme.of(context).colorScheme.primary.withAlpha(99),
              ],
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: Column(
                children: <Widget>[
                  const Appbar(),
                  const DateWidget(),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text(
                        'Categories',
                        style: TextStyle(color: Colors.white.withOpacity(0.75)),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Icon(Icons.draw,color: Colors.white.withOpacity(0.75),size: 16,)
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    children: [
                      CustomElevatedButton(
                        onPressed: () {},
                        text: 'All',
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      CustomElevatedButton(
                        onPressed: () {},
                        text: 'Done',
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      CustomElevatedButton(
                        onPressed: () {},
                        text: 'Pending',
                      ),
                    ],
                  ),
                  const SizedBox(height: 50,),
                  Row(
                    children: [
                      Text(
                        'your Todo Items',
                        style: TextStyle(color: Colors.white.withOpacity(0.75)),
                      ),
                      const SizedBox(width: 5,),
                      Icon(
                        Icons.task_alt,
                        color: Colors.white.withOpacity(0.75),
                        size: 16,
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Add new item',
        child: const Icon(Icons.add),
      ),
    );
  }
}
