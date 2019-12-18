import 'package:django_nas_mobile/home/PlatformWidgets/DesktopSidebar.dart';
import 'package:django_nas_mobile/models/SelectionProvider.dart';
import 'package:django_nas_mobile/models/UploadDownloadProvider.dart';
import 'package:django_nas_mobile/upload/UploadPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DesktopView extends StatelessWidget {
  final Widget body;

  DesktopView({this.body});

  @override
  Widget build(BuildContext context) {
    SelectionProvider selectionProvider = Provider.of(context);
    UploadDownloadProvider provider = Provider.of(context);
    bool show =
        provider.items.length > 0 && selectionProvider.currentIndex == 0;

    if (show == null) {
      print("a");
    }

    return Row(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: DesktopSidebar(),
        ),
        Expanded(
          flex: 9,
          child: Stack(
            children: <Widget>[
              body,
              show
                  ? TotalUploadProgress(
                      key: Key("homepage-progress"),
                      right: 20,
                    )
                  : Container(),
            ],
          ),
        )
      ],
    );
  }
}
