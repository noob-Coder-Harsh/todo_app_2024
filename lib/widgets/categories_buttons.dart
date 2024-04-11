import 'package:flutter/material.dart';

import 'custom_button.dart';

class CategoriesButtons extends StatefulWidget {
  @override
  State<CategoriesButtons> createState() => _CategoriesButtonsState();
}

class _CategoriesButtonsState extends State<CategoriesButtons> {
  String _filterBy = 'All'; // Initialize filter to 'All'
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Categories',
              style: TextStyle(color: Colors.white.withOpacity(0.75)),
            ),
            const SizedBox(
              width: 5,
            ),
            Icon(
              Icons.draw,
              color: Colors.white.withOpacity(0.75),
              size: 16,
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              CustomElevatedButton(
                onPressed: () {
                  setState(() {
                    _filterBy = 'All';
                  });
                },
                text: 'All',
              ),
              CustomElevatedButton(
                onPressed: () {
                  setState(() {
                    _filterBy = 'Done';
                  });
                },
                text: 'Done',
              ),
              CustomElevatedButton(
                onPressed: () {
                  setState(() {
                    _filterBy = 'Pending';
                  });
                },
                text: 'Pending',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
