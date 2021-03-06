import 'dart:io';

import 'package:django_nas_mobile/home/HomePage.dart';
import 'package:django_nas_mobile/home/components/ConfirmDialog.dart';
import 'package:django_nas_mobile/home/views/EditorView.dart';
import 'package:django_nas_mobile/home/views/ImageView.dart';
import 'package:django_nas_mobile/models/DesktopController.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:django_nas_mobile/models/UploadDownloadProvider.dart';
import 'package:django_nas_mobile/models/utils.dart';
import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'components/ErrorDialog.dart';

enum IconType { folder, file, document, image, video }
const IMAGES = ['.jpg', '.png', 'bpm', '.gif', 'jpeg', 'HEIC'];
const VIDEOS = ['.mov', '.mp4', '.m4v'];

class ParentFolderRow extends StatelessWidget {
  final Function onDrag;
  ParentFolderRow({@required this.onDrag});

  @override
  Widget build(BuildContext context) {
    return DragTarget<BaseElement>(
      key: Key("parent-row"),
      onAccept: (data) async {
        NasProvider nasProvider = Provider.of(context);
        DesktopController desktopController = Provider.of(context);
        try {
          await onDragMoveBack(
              data: data,
              desktopController: desktopController,
              nasProvider: nasProvider,
              element: BaseElement(id: nasProvider.currentFolder.parent));
          await this.onDrag();
        } catch (err) {
          showDialog(
            context: context,
            builder: (ctx) => ErrorDialog(
              error: err.toString(),
              title: "Move file/folder error",
            ),
          );
        }
      },
      builder: (context, candidates, rejects) {
        return ListTile(
          // onTap: () {
          //   Navigator.pop(context);
          // },
          selected: candidates.length > 0,
          title: Text("Parent folder"),
        );
      },
    );
  }
}

class FileRow extends StatelessWidget {
  final NasFile file;

  FileRow({@required this.file});

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<BaseElement>(
      key: Key("file-row"),
      data: file,
      feedback: OnDraggingWidget(
        title: p.basename(file.filename),
        icon: renderMobileIcon(path: file.filename, file: file),
      ),
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        secondaryActions: <Widget>[
          IconSlideAction(
            onTap: () async {
              showDialog(
                context: context,
                builder: (ctx) => ConfirmDialog(
                  title: "Do you want to delete this file",
                  content: "You cannot undo this action",
                  onConfirm: () async {
                    NasProvider provider = Provider.of(context, listen: false);
                    await provider.deleteFile(file);
                  },
                ),
              );
            },
            icon: Icons.delete,
            caption: "Delete",
            color: Colors.red,
          ),
          IconSlideAction(
              color: Colors.blue,
              icon: Icons.edit,
              caption: "Rename",
              onTap: () {
                TextEditingController controller = TextEditingController(
                    text: p.basenameWithoutExtension(file.filename));
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text("Rename Folder"),
                    content: TextField(
                      controller: controller,
                      decoration: InputDecoration(labelText: "Folder Name"),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () async {
                          NasProvider provider =
                              Provider.of(context, listen: false);
                          await provider.updateFileName(file,
                              controller.text + p.extension(file.filename));
                          Navigator.pop(context);
                        },
                        child: Text("OK"),
                      )
                    ],
                  ),
                );
              }),
          if (Platform.isMacOS)
            IconSlideAction(
              onTap: () async {
                await downloadFile(context,
                    uploadDownloadProvider: Provider.of(context, listen: false),
                    file: file);
              },
              icon: Icons.file_download,
              caption: "Download",
              color: Colors.blue,
            )
        ],
        child: ListTile(
          onTap: () async {
            await onFileTap(context: context, file: file);
          },
          leading: renderMobileIcon(path: file.filename, file: file),
          title: Text(p.basename(file.filename)),
          subtitle: Text(getSize(file.size)),
          trailing: IconButton(
            icon: Icon(Icons.more_horiz),
          ),
        ),
      ),
    );
  }
}

class FolderRow extends StatelessWidget {
  final NasFolder folder;
  final Function onDrag;

  FolderRow({@required this.folder, @required this.onDrag});

  @override
  Widget build(BuildContext context) {
    return DragTarget<BaseElement>(
      onAccept: (data) async {
        NasProvider nasProvider = Provider.of(context, listen: false);
        try {
          await onDragMoveTo(
              data: data, nasProvider: nasProvider, element: folder);
          await this.onDrag();
        } catch (err) {
          showDialog(
            context: context,
            builder: (ctx) => ErrorDialog(
              error: err.toString(),
              title: "Move folder error",
            ),
          );
        }
      },
      builder: (context, candidates, rejects) {
        if (candidates.length > 0) {
          return buildFolder(context, isSelected: true);
        }
        return buildFolder(context);
      },
    );
  }

  Widget buildFolder(BuildContext context, {bool isSelected = false}) {
    return LongPressDraggable<BaseElement>(
      key: Key("folder-row"),
      data: folder,
      feedback: OnDraggingWidget(
        title: folder.name,
        icon: Image.asset(
          "assets/icons/folder.png",
          height: 40,
        ),
      ),
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        secondaryActions: <Widget>[
          IconSlideAction(
            onTap: () async {
              showDialog(
                context: context,
                builder: (ctx) => ConfirmDialog(
                  title: "Do you want to delete this folder",
                  content: "You cannot undo this action",
                  onConfirm: () async {
                    NasProvider provider = Provider.of(context, listen: false);
                    await provider.deleteFolder(folder);
                  },
                ),
              );
            },
            icon: Icons.delete,
            caption: "Delete",
            color: Colors.red,
          ),
          IconSlideAction(
            onTap: () {
              TextEditingController controller =
                  TextEditingController(text: folder.name);
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text("Rename Folder"),
                  content: TextField(
                    controller: controller,
                    decoration: InputDecoration(labelText: "Folder Name"),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () async {
                        NasProvider provider =
                            Provider.of(context, listen: false);
                        await provider.updateFolder(controller.text, folder.id);
                        Navigator.pop(context);
                      },
                      child: Text("OK"),
                    )
                  ],
                ),
              );
            },
            color: Colors.blue,
            icon: Icons.edit,
            caption: "Rename",
          )
        ],
        child: ListTile(
          selected: isSelected,
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) {
                return HomePage(
                  folderID: folder.id,
                  name: folder.name,
                );
              }),
            );
            await this.onDrag();
          },
          leading: Image.asset(
            "assets/icons/folder.png",
            width: 40,
          ),
          title: Text(folder.name),
          subtitle: Text(getSize(folder.totalSize)),
          trailing: IconButton(
            icon: Icon(Icons.more_horiz),
          ),
        ),
      ),
    );
  }
}

class DocumentRow extends StatelessWidget {
  final NasDocument document;

  DocumentRow({@required this.document});

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<BaseElement>(
      key: Key("document-row"),
      data: document,
      feedback: OnDraggingWidget(
        title: document.name,
        icon: Image.asset(
          "assets/icons/doc.png",
          width: 40,
        ),
      ),
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        secondaryActions: <Widget>[
          IconSlideAction(
            onTap: () async {
              showDialog(
                context: context,
                builder: (ctx) => ConfirmDialog(
                  title: "Do you want to delete this document",
                  content: "You cannot undo this action",
                  onConfirm: () async {
                    NasProvider provider = Provider.of(context, listen: false);
                    await provider.deleteDocument(document);
                  },
                ),
              );
            },
            icon: Icons.delete,
            caption: "Delete",
            color: Colors.red,
          ),
          IconSlideAction(
            onTap: () {
              TextEditingController controller =
                  TextEditingController(text: document.name);
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text("Rename Folder"),
                  content: TextField(
                    controller: controller,
                    decoration: InputDecoration(labelText: "Folder Name"),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () async {
                        NasProvider provider =
                            Provider.of(context, listen: false);
                        await provider.updateDocumentName(
                            controller.text, document.id);
                        Navigator.pop(context);
                      },
                      child: Text("OK"),
                    )
                  ],
                ),
              );
            },
            color: Colors.blue,
            icon: Icons.edit,
            caption: "Rename",
          )
        ],
        child: ListTile(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) {
                return EditorView(
                  id: document.id,
                  name: document.name,
                );
              }),
            );
          },
          leading: Image.asset(
            "assets/icons/doc.png",
            width: 40,
          ),
          title: Text(document.name),
          trailing: IconButton(
            icon: Icon(Icons.more_horiz),
          ),
        ),
      ),
    );
  }
}

class OnDraggingWidget extends StatelessWidget {
  final Widget icon;
  final String title;

  OnDraggingWidget({@required this.icon, @required this.title});

  @override
  Widget build(BuildContext context) {
    // return Material(
    //   child: Container(
    //     color: Colors.transparent,
    //     height: 40,
    //     width: MediaQuery.of(context).size.width,
    //     child: ListTile(
    //       leading: this.icon,
    //       title: Text(this.title),
    //     ),
    //   ),
    // );
    return this.icon;
  }
}
