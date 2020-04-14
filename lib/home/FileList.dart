import 'package:django_nas_mobile/home/Row.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/bezier_hour_glass_header.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/taurus_header.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';

/// Create File List Widget
/// This will render main file list
class FileListWidget extends StatelessWidget {
  final NasFolder currentFolder;
  final Function refresh;

  FileListWidget({
    @required this.currentFolder,
    @required this.refresh,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NasProvider provider = Provider.of(context);
    int length = 0;

    if (currentFolder != null) {
      length = currentFolder.documents.length +
          currentFolder.folders.length +
          currentFolder.files.length;
    }

    return EasyRefresh(
      key: Key("refresh-widget"),
      header: TaurusHeader(),
      firstRefresh: true,
      onRefresh: () async {
        await this.refresh();
      },
      child: ListView.builder(
        key: Key("Mobile Filelist"),
        itemCount: length == 0 ? 0 : length + 1,
        itemBuilder: (ctx, index) {
          // Render previous folder
          if (index == 0) {
            return provider.currentFolder.parents.length > 0
                ? ParentFolderRow(
                    onDrag: this.refresh,
                  )
                : Container();
          }
          // put index back (-1)
          index = index - 1;

          if (index >= 0 && index < currentFolder.folders.length) {
            return FolderRow(
              onDrag: this.refresh,
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
