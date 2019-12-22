import 'package:django_nas_mobile/home/HomePage.dart';
import 'package:django_nas_mobile/home/Row.dart';
import 'package:django_nas_mobile/home/components/ErrorDialog.dart';
import 'package:django_nas_mobile/home/views/EditorView.dart';
import 'package:django_nas_mobile/models/DesktopController.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:django_nas_mobile/models/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;

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
          controller.selectedElement = null;
          await onDragMoveTo(
              nasProvider: nasProvider,
              data: data,
              element: folder,
              desktopController: controller);
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
    NasProvider provider = Provider.of(context);

    return Listener(
      onPointerDown: (_) {
        controller.selectedElement = folder;
      },
      child: GestureDetector(
        onDoubleTap: () async {
          controller.selectedElement = null;
          provider.isLoading = true;
          await provider.fetchFolder(folder.id);
          // Navigator.of(context).push(
          //   MaterialPageRoute(builder: (ctx) {
          //     return HomePage(
          //       folderID: folder.id,
          //       name: folder.name,
          //     );
          //   }),
          // );
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
      ),
    );
  }
}

class DesktopFileItem extends StatelessWidget {
  final NasFile file;

  DesktopFileItem({@required this.file});

  @override
  Widget build(BuildContext context) {
    DesktopController controller = Provider.of(context);
    NasProvider nasProvider = Provider.of(context);
    bool isSelected = controller.selectedElement == file;

    return buildFile(context, isSelected: isSelected);
  }

  Widget buildFile(BuildContext context, {bool isSelected}) {
    DesktopController controller = Provider.of(context);

    Widget _renderIcon({String path}) {
      if (IMAGES.contains(p.extension(path).toLowerCase())) {
        return Image.asset(
          "assets/icons/picture.png",
          key: Key("image-$path"),
          width: 100,
        );
      } else if (VIDEOS.contains(p.extension(path).toLowerCase())) {
        return file.cover != null
            ? Image.network(
                file.cover,
                key: Key("video-nc-$path"),
                width: 160,
                height: 90,
                fit: BoxFit.cover,
              )
            : Image.asset(
                "assets/icons/player.png",
                key: Key("video-$path"),
                width: 100,
              );
      }
      return Image.asset(
        "assets/icons/file.png",
        key: Key("file-$path"),
        width: 100,
      );
    }

    return Listener(
      onPointerDown: (_) {
        controller.selectedElement = file;
      },
      child: GestureDetector(
        onDoubleTap: () async {
          await onFileTap(context: context, file: file);
          controller.selectedElement = file;
        },
        child: Draggable<BaseElement>(
          data: file,
          feedback: OnDraggingWidget(
            icon: _renderIcon(path: file.file),
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
                    _renderIcon(path: file.file),
                    Text(
                      "${p.basename(file.filename)}",
                      softWrap: true,
                      overflow: TextOverflow.clip,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "${getSize(file.size)}",
                      style: Theme.of(context).textTheme.caption,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DesktopDocumentItem extends StatelessWidget {
  final NasDocument document;

  DesktopDocumentItem({@required this.document});

  @override
  Widget build(BuildContext context) {
    DesktopController controller = Provider.of(context);
    NasProvider nasProvider = Provider.of(context);
    bool isSelected = controller.selectedElement == document;

    return buildDocument(context, isSelected: isSelected);
  }

  Widget buildDocument(BuildContext context, {bool isSelected}) {
    DesktopController controller = Provider.of(context);

    return Listener(
      onPointerDown: (_) {
        controller.selectedElement = document;
      },
      child: GestureDetector(
        onDoubleTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) {
              return EditorView(
                id: document.id,
                name: document.name,
              );
            }),
          );
        },
        child: Draggable<BaseElement>(
          data: document,
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
                      "assets/icons/doc.png",
                      width: 100,
                    ),
                    Text(
                      "${document.name}",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
