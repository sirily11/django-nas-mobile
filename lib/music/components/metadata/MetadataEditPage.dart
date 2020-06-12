import 'package:django_nas_mobile/home/components/ErrorDialog.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/MusicProvider.dart';
import 'package:django_nas_mobile/music/components/InitProgressDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:json_schema_form/json_textform/JSONSchemaForm.dart';
import 'package:provider/provider.dart';

class MetadataEditPage extends StatelessWidget {
  final MusicMetadata metadata;

  MetadataEditPage({@required this.metadata});

  @override
  Widget build(BuildContext context) {
    var value = metadata.toJson();

    MusicProvider provider = Provider.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: provider.getMusicDataSchema(),
        builder: (c, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: InitLoadingProgressDialog(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("${snapshot.error}"),
            );
          }
          return JSONSchemaForm(
            schema: snapshot.data,
            values: value,
            url: "${provider.baseURL}/api",
            onSubmit: (v) async {
              try {
                await provider.updateMusicMetadata(metadata.id, v);
                Navigator.pop(context);
              } catch (err) {
                showDialog(
                  context: context,
                  builder: (c) => ErrorDialog(
                    error: err,
                    title: "Update metadata error",
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
