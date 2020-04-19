import 'package:dio/dio.dart';
import 'package:django_nas_mobile/home/components/ErrorDialog.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:flutter/material.dart';
import 'package:json_schema_form/json_textform/JSONSchemaForm.dart';
import 'package:provider/provider.dart';

class BookEditDetail extends StatefulWidget {
  final BookCollection collection;

  BookEditDetail({@required this.collection});

  @override
  _BookEditDetailState createState() => _BookEditDetailState();
}

class _BookEditDetailState extends State<BookEditDetail> {
  @override
  Widget build(BuildContext context) {
    NasProvider provider = Provider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit"),
      ),
      body: FutureBuilder(
        future: provider.fetchBookCollectionSchema(),
        builder: (c, s) {
          if (!s.hasData) {
            return LinearProgressIndicator();
          }
          return JSONSchemaForm(
            schema: s.data,
            onSubmit: (v) async {
              try {
                await provider.updateBookCollection(widget.collection.id, v);
                Navigator.pop(context);
              } catch (err) {
                showDialog(
                  context: context,
                  builder: (c) => ErrorDialog(
                    error: err,
                    title: "Edit Error",
                  ),
                );
              }
            },
            values: {
              "description": widget.collection.description,
              "name": widget.collection.name
            },
          );
        },
      ),
    );
  }
}
