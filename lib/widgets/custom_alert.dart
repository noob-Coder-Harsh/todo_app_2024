import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String actionButtonText;

  const CustomAlertDialog({super.key,
    required this.actionButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm'),
      content: const Text("Are you sure"),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: (){
            Navigator.of(context).pop(true);
          },
          child: Text(actionButtonText),
        ),
      ],
    );
  }
}
