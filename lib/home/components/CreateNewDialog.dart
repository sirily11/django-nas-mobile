import 'package:flutter/material.dart';

class CreateNewDialog extends StatelessWidget {
  final TextEditingController editingController;
  final Function onSubmit;
  final String title;
  final String fieldName;

  CreateNewDialog(
      {@required this.editingController,
      @required this.title,
      this.onSubmit,
      @required this.fieldName});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Create new $title"),
      content: TextField(
        controller: editingController,
        decoration: InputDecoration(labelText: fieldName),
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel"),
        ),
        FlatButton(
          onPressed: () async {
            try {
              await this.onSubmit();
              Navigator.pop(context);
            } catch (err) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text("Creation error"),
                  content: Text("$err"),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Cancel"),
                    ),
                  ],
                ),
              );
            }
          },
          child: Text("OK"),
        )
      ],
    );
  }
}
