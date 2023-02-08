import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConfirmationDialog extends AlertDialog {

  final Function onConfirm;
  final String path;
  final int songsCount;

  ConfirmationDialog({required this.onConfirm, required this.path, required this.songsCount});

  AlertDialog build(BuildContext context) {
    return AlertDialog(
      title: Text('Settings'),
      content: Container(
        height: 50,
        width: 400,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Center(
            child: Text("${songsCount} songs moved to ${path}."),
          ),
        ),
      ),
      actions: [
        Center(
          child: TextButton(
            onPressed: () {
              onConfirm();
            },
            child: Text("OK"),
          ),
        ),
      ],
    );
  }
}
