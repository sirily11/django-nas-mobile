import 'package:django_nas_mobile/models/SelectionProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DesktopSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SelectionProvider selectionProvider = Provider.of(context);
    List<IconData> icons = [
      Icons.home,
      Icons.queue,
      Icons.settings,
      Icons.info
    ];

    return Hero(
      tag: Key("sidebar"),
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: ListView(
          children: ["Home", "Transfer", "Settings", "Info"]
              .asMap()
              .map(
                (i, t) => MapEntry(
                  i,
                  MaterialButton(
                    height: 100,
                    onPressed: () async {
                      selectionProvider.currentIndex = i;
                    },
                    child: Column(
                      children: <Widget>[
                        Icon(
                          icons[i],
                          color: selectionProvider.currentIndex == i
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).unselectedWidgetColor,
                        ),
                        Text(
                          t,
                          style: TextStyle(
                              color: selectionProvider.currentIndex == i
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).unselectedWidgetColor),
                        )
                      ],
                    ),
                  ),
                ),
              )
              .values
              .toList(),
        ),
      ),
    );
  }
}
