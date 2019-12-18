import 'package:django_nas_mobile/home/FileList.dart';
import 'package:django_nas_mobile/models/SelectionProvider.dart';
import 'package:django_nas_mobile/models/UploadDownloadProvider.dart';
import 'package:django_nas_mobile/upload/UploadPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MobileView extends StatelessWidget {
  final Widget body;

  MobileView({@required this.body});

  @override
  Widget build(BuildContext context) {
    SelectionProvider selectionProvider = Provider.of(context);
    UploadDownloadProvider provider = Provider.of(context);
    bool show =
        provider.items.length > 0 && selectionProvider.currentIndex == 0;
    return Stack(
      children: <Widget>[
        body,
        Container(
          child: show
              ? TotalUploadProgress(
                  key: Key("homepage-progress"),
                  right: 0,
                  bottom: 0,
                  width: MediaQuery.of(context).size.width,
                )
              : Container(),
        )
      ],
    );
  }
}
