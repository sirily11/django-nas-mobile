import 'package:django_nas_mobile/drawer/DrawerPanel.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:django_nas_mobile/music/components/InitProgressDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/ball_pulse_header.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:provider/provider.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';

import 'LogsDetail.dart';

class LogsPage extends StatefulWidget {
  @override
  _LogsPageState createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  PaginationResult<Logs> result;
  List<Logs> logs = [];

  @override
  Widget build(BuildContext context) {
    NasProvider provider = Provider.of(context);
    return Scaffold(
      appBar: AppBar(),
      drawer: DrawerPanel(),
      body: EasyRefresh(
        firstRefresh: true,
        firstRefreshWidget: InitLoadingProgressDialog(),
        header: BallPulseHeader(),
        onRefresh: () async {
          var response = await provider.fetchLogs();
          if (response != null) {
            setState(() {
              result = response;
              logs = response.results;
            });
          }
        },
        onLoad: () async {
          if (result?.next != null) {
            var response = await provider.fetchLogs(url: result.next);
            if (response != null) {
              setState(() {
                result = response;
                logs.addAll(response.results);
              });
            }
          }
        },
        child: Timeline.builder(
          lineColor: Theme.of(context).textTheme.bodyText1.color,
          shrinkWrap: true,
          itemCount: logs.length,
          position: TimelinePosition.Left,
          itemBuilder: (c, i) {
            var log = logs[i];
            return TimelineModel(
              Card(
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => LogsDetail(
                          log: log,
                        ),
                      ),
                    );
                  },
                  title: Text("${log.title}"),
                  subtitle: Text("${log.logType}\n${log.sender}"),
                  trailing: Text(
                      "${log.time.year}-${log.time.month}-${log.time.day}"),
                ),
              ),
              position: TimelineItemPosition.random,
              leading: Text("$i"),
            );
          },
        ),
      ),
    );
  }
}
