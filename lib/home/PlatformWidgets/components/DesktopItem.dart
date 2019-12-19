import 'package:django_nas_mobile/home/Row.dart';
import 'package:django_nas_mobile/models/DesktopController.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DesktopFolderItem extends StatelessWidget {
  final NasFolder folder;

  DesktopFolderItem({@required this.folder});

  @override
  Widget build(BuildContext context) {
    DesktopController controller = Provider.of(context);

    return DragTarget<BaseElement>(
      onAccept: (data) {},
      builder: (context, candidates, rejects) {
        if (candidates.length > 0) {
          return buildFolder(context, isSelected: true);
        }
        return buildFolder(context,
            isSelected: controller.selectedElement == folder);
      },
    );
  }

  Widget buildFolder(BuildContext context, {bool isSelected}) {
    DesktopController controller = Provider.of(context);

    return GestureDetector(
      onTapDown: (_) {
        controller.selectedElement = folder;
      },
      child: Draggable<BaseElement>(
        data: folder,
        feedback: OnDraggingWidget(
          icon: Image.asset(
            "assets/icons/folder.png",
            width: 100,
          ),
          title: "",
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: new BorderRadius.circular(8.0),
            child: Container(
              color: isSelected
                  ? Theme.of(context).textSelectionColor.withOpacity(0.7)
                  : null,
              child: Column(
                children: <Widget>[
                  Image.asset(
                    "assets/icons/folder.png",
                    width: 100,
                  ),
                  Text("${folder.name}"),
                  Text(
                    "${getSize(folder.totalSize)}",
                    style: Theme.of(context).textTheme.caption,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
