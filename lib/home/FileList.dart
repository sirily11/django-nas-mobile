import 'package:django_nas_mobile/home/Row.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';

import 'components/LoadingShimmerList.dart';

/// Create File List Widget
/// This will render main file list
class FileListWidget extends StatelessWidget {
  const FileListWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NasProvider provider = Provider.of(context);
    NasFolder currentfolder = provider.currentFolder;

    if (currentfolder == null) {
      return Container(
        key: Key("empty-folder"),
      );
    }
    int length = currentfolder.documents.length +
        currentfolder.folders.length +
        currentfolder.files.length;

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 100),
      child: provider.isLoading
          ? LoadingShimmerList(
              key: Key("Loading Progress"),
            )
          : LiquidPullToRefresh(
              color: Theme.of(context).primaryColor,
              showChildOpacityTransition: false,
              key: Key("refresh-widget"),
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

                  if (index >= 0 && index < currentfolder.folders.length) {
                    return FolderRow(
                      folder: currentfolder.folders[index],
                    );
                  } else if (index >= currentfolder.folders.length &&
                      index <
                          currentfolder.documents.length +
                              currentfolder.folders.length) {
                    int prevIndex = currentfolder.folders.length;
                    return DocumentRow(
                      document: currentfolder.documents[index - prevIndex],
                    );
                  } else if (index >=
                          currentfolder.documents.length +
                              currentfolder.folders.length &&
                      index < length) {
                    int prevIndex = currentfolder.folders.length +
                        currentfolder.documents.length;
                    return FileRow(
                      file: currentfolder.files[index - prevIndex],
                    );
                  }
                },
              ),
            ),
    );
  }
}
