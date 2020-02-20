import 'package:django_nas_mobile/home/PlatformWidgets/components/DesktopItem.dart';
import 'package:django_nas_mobile/home/components/LoadingShimmerList.dart';
import 'package:django_nas_mobile/models/DesktopController.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class DesktopFileGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    NasProvider nasProvider = Provider.of(context);
    DesktopController controller = Provider.of(context);

    NasFolder currentFolder = nasProvider.currentFolder;
    int length = 0;
    if (currentFolder != null) {
      length = currentFolder.documents.length +
          currentFolder.folders.length +
          currentFolder.files.length;
    }

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 100),
      child: nasProvider.isLoading
          ? Center(child: Image.asset("assets/icons/animat-code-color.gif"))
          : Scrollbar(
              child: StaggeredGridView.countBuilder(
                itemCount: length,
                crossAxisCount: 10,
                staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
                itemBuilder: (context, index) {
                  if (index >= 0 && index < currentFolder.folders.length) {
                    return DesktopFolderItem(
                      folder: currentFolder.folders[index],
                    );
                  } else if (index >= currentFolder.folders.length &&
                      index <
                          currentFolder.documents.length +
                              currentFolder.folders.length) {
                    int prevIndex = currentFolder.folders.length;
                    return DesktopDocumentItem(
                      document: currentFolder.documents[index - prevIndex],
                    );
                  } else if (index >=
                          currentFolder.documents.length +
                              currentFolder.folders.length &&
                      index < length) {
                    int prevIndex = currentFolder.folders.length +
                        currentFolder.documents.length;
                    return DesktopFileItem(
                      file: currentFolder.files[index - prevIndex],
                    );
                  }
                  return Container();
                },
              ),
            ),
    );
  }
}
