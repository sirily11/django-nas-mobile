import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String error;

  ErrorDialog({@required this.title, @required this.error});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("$title"),
      content: Text("$error"),
      actions: <Widget>[
        FlatButton(
          child: Text("OK"),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}
