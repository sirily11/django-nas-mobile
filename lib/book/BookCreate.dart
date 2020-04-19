import 'package:dio/dio.dart';
import 'package:django_nas_mobile/home/components/ErrorDialog.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:flutter/material.dart';
import 'package:json_schema_form/json_textform/JSONSchemaForm.dart';
import 'package:provider/provider.dart';

class BookCreate extends StatelessWidget {
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
                await provider.createNewBookCollection(v);
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
          );
        },
      ),
    );
  }
}
