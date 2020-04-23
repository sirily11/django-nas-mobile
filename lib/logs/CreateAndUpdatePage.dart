import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:flutter/material.dart';
import 'package:json_schema_form/json_textform/JSONSchemaForm.dart';
import 'package:json_schema_form/json_textform/models/Icon.dart';
import 'package:provider/provider.dart';

class CreateAndUpdatePage extends StatelessWidget {
  final Map<String, dynamic> defaultValue;
  CreateAndUpdatePage({this.defaultValue});

  @override
  Widget build(BuildContext context) {
    NasProvider provider = Provider.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: provider.getLogSchema(),
        builder: (c, snapshot) {
          if (!snapshot.hasData) {
            return LinearProgressIndicator();
          }
          return JSONSchemaForm(
            schema: snapshot.data,
            useDropdownButton: true,
            values: defaultValue,
            onSubmit: (v) async {
              if (defaultValue != null) {
                await provider.updateLog(defaultValue['id'], v);
              } else {
                await provider.addLog(v);
              }
              Navigator.pop(context);
            },
            icons: [
              FieldIcon(schemaName: "log_type", iconData: Icons.pages),
            ],
          );
        },
      ),
    );
  }
}
