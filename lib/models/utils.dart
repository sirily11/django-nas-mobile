import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as p;
import 'package:django_nas_mobile/home/Row.dart';
import 'package:django_nas_mobile/home/components/ErrorDialog.dart';
import 'package:django_nas_mobile/home/components/UpdateDialog.dart';
import 'package:django_nas_mobile/home/views/ImageView.dart';
import 'package:django_nas_mobile/models/DesktopController.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:django_nas_mobile/models/UploadDownloadProvider.dart';
import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zefyr/zefyr.dart';
import 'package:path/path.dart' as p;

/// get string representation of size
/// [size] size of file in bytes
/// if size >= 1024, then returns in kb
/// if size >= 1024kb, then returns in MB
/// if size >= 1024 mb, then returns in GB
/// if size >= 1024 gb, then returns in TB
/// if size >= 1024 TB, then returns in PB
String getSize(double size) {
  if (size == 0) {
    return "Empty";
  } else if (size >= pow(1024, 1) && size < pow(1024, 2)) {
    String sizeStr = (size / pow(1024, 1)).toStringAsFixed(2);
    return "$sizeStr KB";
  } else if (size >= pow(1024, 2) && size < pow(1024, 3)) {
    String sizeStr = (size / pow(1024, 2)).toStringAsFixed(2);
    return "$sizeStr MB";
  } else if (size >= pow(1024, 3) && size < pow(1024, 4)) {
    String sizeStr = (size / pow(1024, 3)).toStringAsFixed(2);
    return "$sizeStr GB";
  } else if (size >= pow(1024, 4) && size < pow(1024, 5)) {
    String sizeStr = (size / pow(1024, 4)).toStringAsFixed(2);
    return "$sizeStr TB";
  } else if (size >= pow(1024, 5)) {
    String sizeStr = (size / pow(1024, 5)).toStringAsFixed(2);
    return "$sizeStr PB";
  }
  return "${size.toStringAsFixed(2)} bytes";
}

/// Convert quill data from Quill  to flutter quill data
///
List<dynamic> convertFromQuill(List<dynamic> data) {
  for (var entry in data) {
    if (entry.containsKey("attributes")) {
      Map<String, dynamic> attibutes = entry['attributes'];
      Map<String, dynamic> copy = Map.from(entry['attributes']);
      attibutes.forEach((k, v) {
        switch (k) {
          case "italic":
            copy['i'] = v;
            break;
          case "bold":
            copy['b'] = v;
            break;
          case "link":
            copy['a'] = v;

            break;
          case "header":
            copy['heading'] = v;
            break;
          case "list":
            if (v == "ordered") {
              copy['block'] = "ol";
            } else {
              copy['block'] = 'ul';
            }
            break;
          default:
            break;
        }
        copy.remove(k);
      });
      entry['attributes'] = copy;
    }
  }
  return data;
}

/// Convert Quill flutter to Quill JS
List<dynamic> convertToQuill(NotusDocument document) {
  List<dynamic> data = json.decode(json.encode(document));
  for (var entry in data) {
    if (entry.containsKey("attributes")) {
      Map<String, dynamic> attibutes = entry['attributes'];
      Map<String, dynamic> copy = Map.from(entry['attributes']);
      attibutes.forEach((k, v) {
        switch (k) {
          case "i":
            copy['italic'] = v;
            break;
          case "b":
            copy['bold'] = v;
            break;
          case "a":
            copy['link'] = v;
            break;
          case "heading":
            copy['header'] = v;
            break;

          case "block":
            if (v == "ol") {
              copy['list'] = "ordered";
            } else if (v == "ul") {
              copy['list'] = 'bullet';
            }
            break;
            break;
        }
      });
      entry['attributes'] = copy;
    }
  }
  return data;
}

/// Call this function on Drag target
/// Will move element into folder
Future onDragMoveTo(
    {@required BaseElement data,
    @required NasProvider nasProvider,
    DesktopController desktopController,
    @required BaseElement element}) async {
  if (data == element) {
    return;
  }
  if (data is NasFolder && data.id != element.id) {
    await nasProvider.moveFolderTo(data, element.id);
  } else if (data is NasFile) {
    await nasProvider.moveFileTo(data, element.id);
  } else if (data is NasDocument) {
    await nasProvider.moveDocumentTo(data, element.id);
  } else {
    print("File type is not supported");
  }
  desktopController?.selectedElement = null;
}

/// Drag and remove the data based on type of data
Future onDragRemove(
    {@required BaseElement data,
    @required NasProvider nasProvider,
    @required DesktopController desktopController}) async {
  if (data is NasFolder) {
    await nasProvider.deleteFolder(data);
  } else if (data is NasFile) {
    await nasProvider.deleteFile(data);
  } else if (data is NasDocument) {
    await nasProvider.deleteDocument(data);
  } else {
    print("File type is not supported");
  }
  desktopController?.selectedElement = null;
}

/// Drag and move back the data
Future onDragMoveBack(
    {@required BaseElement data,
    @required NasProvider nasProvider,
    DesktopController desktopController,
    @required BaseElement element}) async {
  if (data == element) {
    return;
  }
  if (data is NasFolder) {
    await nasProvider.moveFolderBack(data, element.id);
  } else if (data is NasFile) {
    await nasProvider.moveFileBack(data, element.id);
  } else if (data is NasDocument) {
    await nasProvider.moveDocumentBack(data, element.id);
  } else {
    print("File type is not supported");
  }
  desktopController?.selectedElement = null;
}

Future onDragRename(
    {@required BaseElement data,
    NasProvider nasProvider,
    BuildContext context,
    @required DesktopController desktopController}) async {
  TextEditingController controller = TextEditingController(text: data.name);
  showDialog(
    context: context,
    builder: (c) => UpdateDialog(
      title: "Name",
      editingController: controller,
      fieldName: "Name",
      onSubmit: () async {
        if (data is NasFolder) {
          await nasProvider.updateFolder(controller.text, data.id);
        } else if (data is NasDocument) {
          await nasProvider.updateDocumentName(controller.text, data.id);
        } else {
          throw ("File type is not supported");
        }
        desktopController?.selectedElement = null;
      },
    ),
  );
}

Future<void> onFileTap({@required NasFile file, BuildContext context}) async {
  if (IMAGES.contains(p.extension(file.filename).toLowerCase())) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return ImageView(
          name: p.basename(file.filename),
          url: file.file,
          nasFile: Platform.isMacOS ? file : null,
        );
      }),
    );
  } else if (VIDEOS.contains(p.extension(file.filename).toLowerCase())) {
    if (await canLaunch(file.file)) {
      await launch(file.file);
    }
  } else {
    if (await canLaunch(file.file)) {
      await launch(file.file);
    }
  }
}

Widget renderMobileIcon(
    {@required String path, @required NasFile file, double size = 40}) {
  if (IMAGES.contains(p.extension(path).toLowerCase())) {
    return Image.asset(
      "assets/icons/picture.png",
      key: Key("image-$path"),
      width: size,
    );
  } else if (VIDEOS.contains(p.extension(path).toLowerCase())) {
    return file.cover != null
        ? Image.network(
            file.cover,
            key: Key("video-nc-$path"),
            width: size,
            fit: BoxFit.cover,
          )
        : Image.asset(
            "assets/icons/player.png",
            key: Key("video-$path"),
            width: size,
          );
  }
  return Image.asset(
    "assets/icons/file.png",
    key: Key("file-$path"),
    width: size,
  );
}

Future downloadFile(BuildContext context,
    {@required UploadDownloadProvider uploadDownloadProvider,
    @required NasFile file}) async {
  FileChooserResult chooserResult = await showSavePanel(
    suggestedFileName: p.basename(file.filename),
  );
  if (!chooserResult.canceled) {
    try {
      await uploadDownloadProvider.downloadItem(
          file.file, chooserResult.paths[0]);
    } catch (err) {
      showDialog(
        context: context,
        builder: (ctx) => ErrorDialog(
          title: "Download Error",
          error: err.toString(),
        ),
      );
    }
  }
}

/// Download multiple files
Future downloadFiles(BuildContext context,
    {@required UploadDownloadProvider uploadDownloadProvider,
    @required List<NasFile> files}) async {
  FileChooserResult chooserResult =
      await showOpenPanel(canSelectDirectories: true);
  if (!chooserResult.canceled) {
    try {
      await uploadDownloadProvider.downloadItems(
          files.map((f) => f.file).toList(),
          files
              .map((f) =>
                  p.join(chooserResult.paths.first, p.basename(f.filename)))
              .toList());
    } catch (err) {
      showDialog(
        context: context,
        builder: (ctx) => ErrorDialog(
          title: "Download Error",
          error: err.toString(),
        ),
      );
    }
  }
}
