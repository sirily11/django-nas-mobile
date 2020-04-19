import 'package:flutter/material.dart';

class Selection<T> {
  String title;
  T value;

  Selection({@required this.title, @required this.value});

  @override
  int get hashCode => super.hashCode;

  @override
  bool operator ==(o) => o is Selection && o.title == title && o.value == value;
}

typedef Future OnSubmit(Selection selected);

class CreateNewDialog<T> extends StatefulWidget {
  final TextEditingController editingController;
  final OnSubmit onSubmit;
  final String title;
  final String fieldName;
  final String selectionFieldName;
  final List<Selection<T>> selections;

  CreateNewDialog({
    @required this.editingController,
    @required this.title,
    this.onSubmit,
    @required this.fieldName,
    this.selectionFieldName,
    this.selections,
  });

  @override
  _CreateNewDialogState createState() => _CreateNewDialogState();
}

class _CreateNewDialogState<T> extends State<CreateNewDialog<T>> {
  Selection<T> selected;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Create new ${widget.title}"),
      content: Container(
        width: MediaQuery.of(context).size.width,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            TextField(
              controller: widget.editingController,
              decoration: InputDecoration(labelText: widget.fieldName),
            ),
            if (widget.selections != null)
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text("${widget.selectionFieldName} Selection"),
                  ),
                  DropdownButton<Selection<T>>(
                    value: selected,
                    hint: Text("Select a value"),
                    items: widget.selections
                        .map(
                          (s) => DropdownMenuItem(
                            child: Text("${s.title}"),
                            value: s,
                          ),
                        )
                        .toList(),
                    onChanged: (Selection<T> value) {
                      setState(() {
                        selected = value;
                      });
                    },
                  ),
                ],
              )
          ],
        ),
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
              await this.widget.onSubmit(selected);
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
