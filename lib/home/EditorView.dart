import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EditorView extends StatelessWidget {
  final int id;
  final String name;

  EditorView({this.id, this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: FutureBuilder<SharedPreferences>(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator(),);
            }
            SharedPreferences prefs = snapshot.data;

            return WebView(
              initialUrl: "${prefs.getString("url")}$editorUrl$id/",
              javascriptMode: JavascriptMode.unrestricted,
            );
          }),
    );
  }
}
