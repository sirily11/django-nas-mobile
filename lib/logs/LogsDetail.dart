import 'package:django_nas_mobile/home/components/ConfirmDialog.dart';
import 'package:django_nas_mobile/logs/CreateAndUpdatePage.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:django_nas_mobile/music/components/InitProgressDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/ball_pulse_header.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

class LogsDetail extends StatefulWidget {
  final Logs log;
  LogsDetail({@required this.log});

  @override
  _LogsDetailState createState() => _LogsDetailState();
}

class _LogsDetailState extends State<LogsDetail> {
  Logs logs;

  @override
  Widget build(BuildContext context) {
    NasProvider provider = Provider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("${logs?.title ?? widget.log.title}"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              showDialog(
                context: context,
                builder: (c) => ConfirmDialog(
                  title: "Do you want to delete?",
                  content: "There is no way of going back",
                  onConfirm: () async {
                    await provider.deleteLog(widget.log.id);
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => CreateAndUpdatePage(
                    defaultValue: logs?.toJson() ?? widget.log.toJson(),
                  ),
                ),
              );
              await fetch(provider);
            },
            icon: Icon(Icons.edit),
          )
        ],
      ),
      body: EasyRefresh(
        firstRefreshWidget: InitLoadingProgressDialog(),
        header: BallPulseHeader(),
        firstRefresh: true,
        onRefresh: () async {
          await fetch(provider);
        },
        child: logs != null
            ? ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Card(
                    child: ListTile(
                      title: Text("Time"),
                      subtitle: Text("${logs.time}"),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text("Sender"),
                      subtitle: Text("${logs.sender}"),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text("Log Type"),
                      subtitle: Text("${logs.logType}"),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text("Content"),
                      subtitle: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: 300),
                        child: MarkdownBody(
                          data: logs?.content ?? "",
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Container(),
      ),
    );
  }

  Future fetch(NasProvider provider) async {
    var l = await provider.getLog(widget.log.id);
    setState(() {
      logs = l;
    });
  }
}
