import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:flutter/material.dart';
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
      body: WebView(
        initialUrl: "$editorUrl$id/",
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
