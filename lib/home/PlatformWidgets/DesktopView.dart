import 'package:django_nas_mobile/home/PlatformWidgets/DesktopSidebar.dart';
import 'package:flutter/material.dart';

class DesktopView extends StatelessWidget {
  final Widget body;

  DesktopView({this.body});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: DesktopSidebar(),
        ),
        Expanded(
          flex: 9,
          child: body,
        )
      ],
    );
  }
}
