import 'package:django_nas_mobile/home/HomePage.dart';
import 'package:django_nas_mobile/home/Row.dart';
import 'package:django_nas_mobile/home/components/ErrorDialog.dart';
import 'package:django_nas_mobile/models/DesktopController.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:django_nas_mobile/models/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DesktopFolderItem extends StatelessWidget {
  final NasFolder folder;

  DesktopFolderItem({@required this.folder});

  @override
  Widget build(BuildContext context) {
    DesktopController controller = Provider.of(context);
    NasProvider nasProvider = Provider.of(context);

    return DragTarget<BaseElement>(
      onAccept: (data) async {
        try {
          await onDragMoveTo(
              nasProvider: nasProvider, data: data, element: folder);
        } catch (err) {
          showDialog(
            context: context,
            builder: (ctx) => ErrorDialog(
              error: err.toString(),
              title: "Move Folder Error",
            ),
          );
        }
      },
      builder: (context, candidates, rejects) {
        if (candidates.length > 0) {
          return buildFolder(context, isSelected: true);
        }
        return buildFolder(context,
            isSelected: controller.selectedElement != null &&
                controller.selectedElement == folder);
      },
    );
  }

  Widget buildFolder(BuildContext context, {bool isSelected}) {
    DesktopController controller = Provider.of(context);

    return GestureDetector(
      onDoubleTap: () {
        controller.selectedElement = folder;
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (ctx) {
            return HomePage(
              folderID: folder.id,
              name: folder.name,
            );
          }),
        );
      },
      onTapDown: (_) {
        if (isSelected) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) {
              return HomePage(
                folderID: folder.id,
                name: folder.name,
              );
            }),
          );
        } else {
          controller.selectedElement = folder;
        }
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
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ClipRRect(
            borderRadius: new BorderRadius.circular(8.0),
            child: Container(
              height: 200,
              color: isSelected
                  ? Theme.of(context).textSelectionColor.withOpacity(0.7)
                  : null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "assets/icons/folder.png",
                    width: 100,
                  ),
                  Text(
                    "${folder.name}",
                    textAlign: TextAlign.center,
                  ),
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
