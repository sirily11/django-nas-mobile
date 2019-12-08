import 'package:django_nas_mobile/home/EditorView.dart';
import 'package:django_nas_mobile/home/HomePage.dart';
import 'package:django_nas_mobile/home/ImageView.dart';
import 'package:django_nas_mobile/home/VideoView.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

enum IconType { folder, file, document, image, video }
const IMAGES = ['.jpg', '.png', 'bpm', '.gif'];
const VIDEOS = ['.mov', '.mp4', '.m4v'];

class ParentFolderRow extends StatelessWidget {
  ParentFolderRow();

  @override
  Widget build(BuildContext context) {
    return DragTarget<BaseElement>(
      onAccept: (data) async {
        NasProvider nasProvider = Provider.of(context);
        var parentID = nasProvider.currentFolder.parent;
        try {
          if (data is NasFolder) {
            await nasProvider.moveFolderBack(data, parentID);
          } else if (data is NasFile) {
            await nasProvider.moveFileBack(data, parentID);
          } else if (data is NasDocument) {
            await nasProvider.moveDocumentBack(data, parentID);
          } else {
            print("File type is not supported");
          }
          nasProvider.update();
        } catch (err) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              content: Text("$err"),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                )
              ],
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

  Widget _renderIcon({String path}) {
    if (IMAGES.contains(p.extension(path).toLowerCase())) {
      return Image.asset(
        "assets/icons/picture.png",
        width: 40,
      );
    } else if (VIDEOS.contains(p.extension(path).toLowerCase())) {
      return Image.asset(
        "assets/icons/player.png",
        width: 40,
      );
    }
    return Image.asset(
      "assets/icons/file.png",
      width: 40,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<BaseElement>(
      data: file,
      feedback: OnDraggingWidget(
        title: p.basename(file.filename),
        icon: _renderIcon(path: file.filename),
      ),
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        secondaryActions: <Widget>[
          IconSlideAction(
            onTap: () async {
              NasProvider provider = Provider.of(context);
              await provider.deleteFile(file);
            },
            icon: Icons.delete,
            caption: "Delete",
            color: Colors.red,
          ),
        ],
        child: ListTile(
          onTap: () async {
            if (IMAGES.contains(p.extension(file.filename).toLowerCase())) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return ImageView(
                    name: p.basename(file.filename),
                    url: file.file,
                  );
                }),
              );
            } else if (VIDEOS
                .contains(p.extension(file.filename).toLowerCase())) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return VideoView(
                    name: p.basename(file.filename),
                    url: file.file,
                  );
                }),
              );
            } else {
              if (await canLaunch(file.file)) {
                await launch(file.file);
              }
            }
          },
          leading: _renderIcon(path: file.filename),
          title: Text(p.basename(file.filename)),
          subtitle: Text("${(file.size / 1024 / 1024).toStringAsFixed(2)}MB"),
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

  FolderRow({@required this.folder});

  @override
  Widget build(BuildContext context) {
    return DragTarget<BaseElement>(
      onAccept: (data) async {
        NasProvider nasProvider = Provider.of(context);
        try {
          if (data is NasFolder && data.id != folder.id) {
            await nasProvider.moveFolderTo(data, folder.id);
          } else if (data is NasFile) {
            await nasProvider.moveFileTo(data, folder.id);
          } else if (data is NasDocument) {
            await nasProvider.moveDocumentTo(data, folder.id);
          } else {
            print("File type is not supported");
          }
        } catch (err) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              content: Text("$err"),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                )
              ],
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
              NasProvider provider = Provider.of(context);
              await provider.deleteFolder(folder);
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
                        NasProvider provider = Provider.of(context);
                        var data = await DataFetcher(url: folderUrl)
                            .update<NasFolder>(
                                folder.id, {"name": controller.text});
                        var f = provider.currentFolder.folders.firstWhere(
                            (f) => f.id == folder.id,
                            orElse: () => null);
                        f.name = controller.text;
                        provider.update();
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
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) {
                return HomePage(
                  folderID: folder.id,
                  name: folder.name,
                );
              }),
            );
          },
          leading: Image.asset(
            "assets/icons/folder.png",
            width: 40,
          ),
          title: Text(folder.name),
          subtitle:
              Text("${(folder.totalSize / 1024 / 1024).toStringAsFixed(2)}MB"),
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
              NasProvider provider = Provider.of(context);
              await provider.deleteDocument(document);
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
                        NasProvider provider = Provider.of(context);
                        var data = await DataFetcher(url: documentUrl)
                            .update<NasDocument>(
                                document.id, {"name": controller.text});
                        var d = provider.currentFolder.documents.firstWhere(
                            (d) => d.id == document.id,
                            orElse: () => null);
                        d.name = controller.text;
                        provider.update();
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
