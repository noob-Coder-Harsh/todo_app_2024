import 'package:flutter/material.dart';

import 'custom_button.dart';

class CategoryButtons extends StatelessWidget{
  const CategoryButtons({super.key});

  @override
  Widget build(BuildContext context){
    return Row(
      children: [
        CustomElevatedButton(
          onPressed: () {}, text: 'All',),
        const SizedBox(width: 5,),
        CustomElevatedButton(
          onPressed: () {}, text: 'Done',),
        const SizedBox(width: 5,),
        CustomElevatedButton(
          onPressed: () {}, text: 'Pending',),
      ],
    );
  }
}