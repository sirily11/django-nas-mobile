import 'dart:async';

import 'package:django_nas_mobile/models/SystemProvider.dart';
import 'package:django_nas_mobile/models/utils.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:provider/provider.dart';

class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 20), (timer) async {
      SystemProvider systemProvider = Provider.of(context);
      await systemProvider.getData();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemProvider systemProvider = Provider.of(context);
    if (systemProvider.systemInfoList.length == 0) {
      return Container();
    }
    var info = systemProvider.systemInfoList.last;
    return Container(
      child: ListView(
        children: <Widget>[
          InfoCard(
            cardName: "CPU",
            title: "Used",
            title2: "Free",
            data1: info.cpu.toString(),
            data2: (100 - info.cpu).toString(),
            unit: "percent",
          ),
          InfoCard(
            cardName: "Disk",
            title: "Used",
            title2: "Total",
            data1: getSize(info.disk.used.toDouble()),
            data2: getSize(info.disk.total.toDouble()),
            unit: "",
          ),
          InfoCard(
            cardName: "Memory",
            title: "Used",
            title2: "Total",
            data1: getSize(info.memory.used.toDouble()),
            data2: getSize(info.memory.total.toDouble()),
            unit: "",
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String cardName;
  final String title;
  final String title2;
  final String data1;
  final String data2;
  final String unit;
  final List<SystemInfo> data;

  InfoCard(
      {@required this.cardName,
      @required this.title,
      @required this.data1,
      @required this.data2,
      @required this.title2,
      @required this.unit,
      this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.computer,
                  color: Colors.orange,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    cardName,
                    style: Theme.of(context)
                        .textTheme
                        .subhead
                        .copyWith(color: Colors.orange),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  buildDetail(context, title, data1, unit, Colors.red),
                  Container(
                    width: 1,
                    height: 40,
                    color: Theme.of(context).dividerColor,
                  ),
                  buildDetail(context, title2, data2, unit, Colors.blue),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildDetail(BuildContext context, String title, String data,
      String unit, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.subhead.copyWith(color: color),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                data,
                style: Theme.of(context).textTheme.headline,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 3),
                child: Text(unit),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// class TimeSeriesBar extends StatelessWidget {
//   final List<charts.Series<SystemInfo, int>> seriesList;
//   final bool animate;

//   TimeSeriesBar(this.seriesList, {this.animate});

//   /// Creates a [TimeSeriesChart] with sample data and no transition.

//   @override
//   Widget build(BuildContext context) {
//     return new charts.TimeSeriesChart(
//       animate: animate,
//       // Set the default renderer to a bar renderer.
//       // This can also be one of the custom renderers of the time series chart.
//       defaultRenderer: new charts.BarRendererConfig<DateTime>(),
//       // It is recommended that default interactions be turned off if using bar
//       // renderer, because the line point highlighter is the default for time
//       // series chart.
//       defaultInteractions: false,
//       // If default interactions were removed, optionally add select nearest
//       // and the domain highlighter that are typical for bar charts.
//       behaviors: [new charts.SelectNearest(), new charts.DomainHighlighter()],
//     );
//   }
// }
