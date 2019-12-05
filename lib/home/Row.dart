import 'package:django_nas_mobile/home/EditorView.dart';
import 'package:django_nas_mobile/home/HomePage.dart';
import 'package:django_nas_mobile/home/ImageView.dart';
import 'package:django_nas_mobile/home/SubDirView.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

enum IconType { folder, file, document, image, video }
const IMAGES = ['.jpg', '.png', 'bpm', '.gif'];
const VIDEOS = ['.mov', '.mp4', '.m4v'];

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
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: <Widget>[
        IconSlideAction(
          onTap: () async {
            NasProvider provider = Provider.of(context);
            await DataFetcher(url: fileUrl).delete<NasFile>(file.id);
            provider.currentFolder.files.removeWhere((f) => f.id == file.id);
            provider.update();
          },
          icon: Icons.delete,
          caption: "Delete",
          color: Colors.red,
        ),
      ],
      child: ListTile(
        onTap: () {
          if (IMAGES.contains(p.extension(file.filename).toLowerCase())) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) {
                return ImageView(
                  name: p.basename(file.filename),
                  url: file.file,
                );
              }),
            );
          }
        },
        leading: _renderIcon(path: file.filename),
        title: Text(p.basename(file.filename)),
        subtitle: Text("${(file.size / 1024 / 1024).toStringAsFixed(2)}MB"),
        trailing: IconButton(
          icon: Icon(Icons.more_horiz),
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
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: <Widget>[
        IconSlideAction(
          onTap: () async {
            NasProvider provider = Provider.of(context);
            await DataFetcher(url: folderUrl).delete<NasFolder>(folder.id);
            provider.currentFolder.folders
                .removeWhere((f) => f.id == folder.id);
            provider.update();
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
    );
  }
}

class DocumentRow extends StatelessWidget {
  final NasDocument document;

  DocumentRow({@required this.document});

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: <Widget>[
        IconSlideAction(
          onTap: () async {
            NasProvider provider = Provider.of(context);
            await DataFetcher(url: documentUrl)
                .delete<NasDocument>(document.id);
            provider.currentFolder.documents
                .removeWhere((d) => d.id == document.id);
            provider.update();
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
    );
  }
}
