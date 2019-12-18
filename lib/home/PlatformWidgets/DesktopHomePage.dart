import 'package:django_nas_mobile/home/FileList.dart';
import 'package:django_nas_mobile/models/SelectionProvider.dart';
import 'package:django_nas_mobile/models/UploadProvider.dart';
import 'package:django_nas_mobile/upload/UploadPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DesktopHomepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SelectionProvider selectionProvider = Provider.of(context);

    UploadProvider provider = Provider.of(context);
    return Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: 20),
          child: FileListWidget(),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 100),
          child:
              provider.items.length > 0 && selectionProvider.currentIndex == 0
                  ? TotalUploadProgress(
                      key: Key("homepage-progress"),
                      right: 40,
                    )
                  : Container(),
        )
      ],
    );
  }
}
