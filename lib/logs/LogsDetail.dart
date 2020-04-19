import 'package:django_nas_mobile/models/Folder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class LogsDetail extends StatelessWidget {
  final Logs log;
  LogsDetail({@required this.log});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${log.time}"),
      ),
      body: Markdown(
        data: log.content,
      ),
    );
  }
}
