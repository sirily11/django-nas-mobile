import 'package:django_nas_mobile/models/DesktopController.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:django_nas_mobile/models/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DesktopToolbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DesktopController desktopController = Provider.of(context);
    NasProvider nasProvider = Provider.of(context);

    bool show = desktopController.selectedElement != null;

    return AnimatedPositioned(
      key: Key("a"),
      bottom: MediaQuery.of(context).size.height / 2,
      right: show ? 0 : -100,
      duration: Duration(milliseconds: 100),
      child: Hero(
        tag: "tool",
        child: Container(
          width: 80,
          child: Card(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DragTarget<BaseElement>(
                    onAccept: (data) async {
                      await onDragMoveTo(
                        data: data,
                        nasProvider: nasProvider,
                        element:
                            BaseElement(id: nasProvider.currentFolder.parent),
                      );
                      desktopController.selectedElement = null;
                    },
                    builder: (context, candidates, rejects) {
                      return buildParent(context);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DragTarget<BaseElement>(
                    onAccept: (data) async {
                      await nasProvider
                          .deleteFolder(desktopController.selectedElement);
                      desktopController.selectedElement = null;
                    },
                    builder: (context, candidates, rejects) {
                      return buildIconDelete(context);
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildIconDelete(BuildContext context) {
    DesktopController desktopController = Provider.of(context);
    NasProvider nasProvider = Provider.of(context);

    return IconButton(
      tooltip: "Delete",
      onPressed: () async {
        await nasProvider.deleteFolder(desktopController.selectedElement);
      },
      iconSize: 30,
      icon: Icon(
        Icons.delete,
        color: Theme.of(context).unselectedWidgetColor,
      ),
    );
  }

  Widget buildParent(BuildContext context) {
    DesktopController desktopController = Provider.of(context);
    NasProvider nasProvider = Provider.of(context);

    return IconButton(
      tooltip: "Parent folder",
      onPressed: () async {
        await nasProvider.deleteFolder(desktopController.selectedElement);
      },
      iconSize: 30,
      icon: Icon(
        Icons.arrow_back_ios,
        color: Theme.of(context).unselectedWidgetColor,
      ),
    );
  }
}
