import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:flutter/material.dart';
import 'package:json_schema_form/JSONSchemaForm.dart';
import 'package:provider/provider.dart';

class CreateNewFolderView extends StatefulWidget {
  final String defaultFolder;
  final int parent;

  CreateNewFolderView({this.defaultFolder, this.parent});
  @override
  _CreateNewFolderViewState createState() => _CreateNewFolderViewState();
}

class _CreateNewFolderViewState extends State<CreateNewFolderView> {
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
          title: Text("Create New Folder"),
          actions: <Widget>[
            IconButton(
              onPressed: () async {
                try {
                  var data = await DataFetcher(url: folderUrl)
                      .create<NasFolder>(
                          {"name": controller.text, "parent": widget.parent});
                  NasProvider provider = Provider.of(context);
                  provider.currentFolder.folders.add(data);
                  provider.update();
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
                          ));
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
            decoration: InputDecoration(labelText: "Folder Name"),
          ),
        ));
  }
}
