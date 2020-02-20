import 'package:django_nas_mobile/home/Row.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/bezier_hour_glass_header.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/taurus_header.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';

import 'components/LoadingShimmerList.dart';

/// Create File List Widget
/// This will render main file list
class FileListWidget extends StatelessWidget {
  final NasFolder currentFolder;

  FileListWidget({
    @required this.currentFolder,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NasProvider provider = Provider.of(context);

    if (currentFolder == null) {
      return Container(
        key: Key("empty-folder"),
      );
    }
    int length = currentFolder.documents.length +
        currentFolder.folders.length +
        currentFolder.files.length;

    return EasyRefresh(
      key: Key("refresh-widget"),
      header: TaurusHeader(),
      onRefresh: () async {
        NasProvider provider = Provider.of(context);
        await provider.refresh(provider.currentFolder.id);
      },
      child: ListView.builder(
        key: Key("Mobile Filelist"),
        itemCount: length + 1,
        itemBuilder: (ctx, index) {
          // Render previous folder
          if (index == 0) {
            return provider.currentFolder.parents.length > 0
                ? ParentFolderRow()
                : Container();
          }
          // put index back (-1)
          index = index - 1;

          if (index >= 0 && index < currentFolder.folders.length) {
            return FolderRow(
              folder: currentFolder.folders[index],
            );
          } else if (index >= currentFolder.folders.length &&
              index <
                  currentFolder.documents.length +
                      currentFolder.folders.length) {
            int prevIndex = currentFolder.folders.length;
            return DocumentRow(
              document: currentFolder.documents[index - prevIndex],
            );
          } else if (index >=
                  currentFolder.documents.length +
                      currentFolder.folders.length &&
              index < length) {
            int prevIndex =
                currentFolder.folders.length + currentFolder.documents.length;
            return FileRow(
              file: currentFolder.files[index - prevIndex],
            );
          }
        },
      ),
    );
  }
}
