import 'package:flutter/material.dart';

class DateWidget extends StatelessWidget{
  const DateWidget({super.key});

  @override
  Widget build(BuildContext context){
    DateTime currentDate = DateTime.now();
    String formattedDate = "${currentDate.day}-${currentDate.month}-${currentDate.year}";

    return Center(
      child: Text(
        formattedDate,
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white.withOpacity(0.90)
        ),
      ),
    );
  }
}