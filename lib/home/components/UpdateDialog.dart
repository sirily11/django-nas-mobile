import 'package:django_nas_mobile/home/components/CreateNewDialog.dart';
import 'package:flutter/material.dart';

class UpdateDialog<T> extends StatefulWidget {
  final TextEditingController editingController;
  final OnSubmit onSubmit;
  final String title;
  final String fieldName;
  final String selectionFieldName;
  final Selection<T> defualtSelection;
  final List<Selection<T>> selections;

  UpdateDialog(
      {@required this.editingController,
      @required this.title,
      this.onSubmit,
      @required this.fieldName,
      this.selectionFieldName,
      this.selections,
      this.defualtSelection});

  @override
  _UpdateDialogState createState() => _UpdateDialogState();
}

class _UpdateDialogState<T> extends State<UpdateDialog<T>> {
  Selection<T> selected;
  @override
  void initState() {
    selected = widget.defualtSelection;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Update ${widget.title}"),
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
                  title: Text("update error"),
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
