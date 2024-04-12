import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:text_3d/text_3d.dart';

class DateWidget extends StatelessWidget {
  const DateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime currentDate = DateTime.now();
    String formattedDate = DateFormat('MMMM d, yyyy').format(currentDate);

    return Center(
      child: ThreeDText(
        text: formattedDate,
        textStyle: TextStyle(fontSize: 32,
          color: Colors.white.withOpacity(0.75),
          fontWeight: FontWeight.bold,
        ),
        depth: 5,
        style: ThreeDStyle.inset,
      ),
    );
  }
}
