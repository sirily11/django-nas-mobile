import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:flutter/material.dart';
import 'package:json_schema_form/JSONSchemaForm.dart';
import 'package:provider/provider.dart';

class CreateNewDocumentView extends StatefulWidget {
  final String defaultFolder;
  final int parent;

  CreateNewDocumentView({this.defaultFolder, this.parent});
  @override
  _CreateNewDocumentViewState createState() => _CreateNewDocumentViewState();
}

class _CreateNewDocumentViewState extends State<CreateNewDocumentView> {
  TextEditingController controller;

  @override
  void initState() {
    super.initState();
    if (widget.defaultFolder != null) {
      controller = TextEditingController(text: widget.defaultFolder);
    } else {
      controller = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Create New Document"),
          actions: <Widget>[
            IconButton(
              onPressed: () async {
                try {
                  NasProvider provider = Provider.of(context);
                  await provider.createNewDocument(controller.text);
                  Navigator.pop(context);
                } catch (err) {
                  showDialog(
                    context: context,
                    builder: (c) => AlertDialog(
                      content: Text("$err"),
                      actions: <Widget>[
                        FlatButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("ok"),
                        )
                      ],
                    ),
                  );
                }
              },
              icon: Icon(Icons.done),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(labelText: "Document Name"),
          ),
        ));
  }
}
