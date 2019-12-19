import 'package:django_nas_mobile/home/PlatformWidgets/components/DesktopItem.dart';
import 'package:django_nas_mobile/home/components/LoadingShimmerList.dart';
import 'package:django_nas_mobile/models/DesktopController.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:flutter/material.dart';
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
    int numberPerRow = (MediaQuery.of(context).size.width / 160).round();

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 200),
      child: currentFolder == null
          ? LoadingShimmerList()
          : GestureDetector(
              onTap: () {
                controller.selectedElement = null;
              },
              child: GridView.builder(
                itemCount: length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: numberPerRow),
                itemBuilder: (context, index) {
                  if (index >= 0 && index < currentFolder.folders.length) {
                    return DesktopFolderItem(
                      folder: currentFolder.folders[index],
                    );
                  }

                  return Container();
                },
              ),
            ),
    );
  }
}
