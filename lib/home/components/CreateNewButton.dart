import 'dart:io';
import 'package:django_nas_mobile/PlatformWidget.dart';
import 'package:django_nas_mobile/home/components/CreateNewDialog.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:django_nas_mobile/models/UploadDownloadProvider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:file_chooser/file_chooser.dart';

class CreateNewButton extends StatelessWidget {
  final Color color;

  CreateNewButton({this.color});

  void _onSelected(int selection, BuildContext context) async {
    UploadDownloadProvider uploadProvider = Provider.of(context);
    NasProvider nasProvider = Provider.of(context);
    // new folder
    if (selection == 0) {
      TextEditingController controller = TextEditingController();
      showDialog(
        context: context,
        builder: (context) => CreateNewDialog(
          editingController: controller,
          title: "Folder",
          fieldName: "Folder Name",
          onSubmit: () async {
            await nasProvider.createNewFolder(controller.text);
          },
        ),
      );
    }
    // new document
    else if (selection == 1) {
      TextEditingController controller = TextEditingController();
      showDialog(
        context: context,
        builder: (context) => CreateNewDialog(
          editingController: controller,
          title: "Document",
          fieldName: "Document Name",
          onSubmit: () async {
            await nasProvider.createNewDocument(controller.text);
          },
        ),
      );
    } else if (selection == 2) {
      List<File> files = await FilePicker.getMultiFile();
      if (files == null) {
        return;
      }
      int parent = nasProvider.currentFolder.id;
      var data = await uploadProvider.addItems(
          files
              .map((f) => UploadDownloadItem(file: f, parent: parent))
              .toList(),
          baseURL: nasProvider.baseURL);
      nasProvider.addFiles(data, data[0].parent);
    } else if (selection == 3) {
      var image = await ImagePicker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        return;
      }
      int parent = nasProvider.currentFolder.id;
      var data = await uploadProvider.addItem(
          UploadDownloadItem(file: image, parent: parent),
          baseURL: nasProvider.baseURL);
      nasProvider.addFile(data, data.parent);
    } else {
      var video = await ImagePicker.pickVideo(
        source: ImageSource.gallery,
      );
      if (video == null) {
        return;
      }
      int parent = nasProvider.currentFolder.id;
      var data = await uploadProvider.addItem(
          UploadDownloadItem(file: video, parent: parent),
          baseURL: nasProvider.baseURL);
      nasProvider.addFile(data, data.parent);
    }
  }

  void _onSelectedDesktop(int selection, BuildContext context) async {
    UploadDownloadProvider uploadProvider = Provider.of(context);
    NasProvider nasProvider = Provider.of(context);

    if (selection == 0) {
      TextEditingController controller = TextEditingController();
      showDialog(
        context: context,
        builder: (context) => CreateNewDialog(
          editingController: controller,
          title: "Folder",
          fieldName: "Folder Name",
          onSubmit: () async {
            await nasProvider.createNewFolder(controller.text);
          },
        ),
      );
    } else if (selection == 1) {
      TextEditingController controller = TextEditingController();
      showDialog(
        context: context,
        builder: (context) => CreateNewDialog(
          editingController: controller,
          title: "Document",
          fieldName: "Document Name",
          onSubmit: () async {
            await nasProvider.createNewDocument(controller.text);
          },
        ),
      );
    } else if (selection == 2) {
      FileChooserResult result =
          await showOpenPanel(allowsMultipleSelection: true);
      if (!result.canceled) {
        List<File> files = result.paths.map((p) => File(p)).toList();
        int parent = nasProvider.currentFolder.id;
        var data = await uploadProvider.addItems(
            files
                .map((f) => UploadDownloadItem(file: f, parent: parent))
                .toList(),
            baseURL: nasProvider.baseURL);
        nasProvider.addFiles(data, data[0].parent);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      desktop: buildPopupMenuButtonDesktop(context),
      largeScreen: buildPopupMenuButtonMobile(context),
      mobile: buildPopupMenuButtonMobile(context),
    );
  }

  PopupMenuButton<int> buildPopupMenuButtonMobile(BuildContext context) {
    return PopupMenuButton<int>(
      onSelected: (int selection) {
        this._onSelected(selection, context);
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: 0,
            child: Text("create new folder"),
          ),
          PopupMenuItem(
            value: 1,
            child: Text("create new document"),
          ),
          PopupMenuItem(
            value: 2,
            child: Text("Upload files"),
          ),
          PopupMenuItem(
            value: 3,
            child: Text("Upload image"),
          ),
          PopupMenuItem(
            value: 4,
            child: Text("Upload video"),
          )
        ];
      },
      icon: Icon(
        Icons.add,
        color: this.color,
      ),
    );
  }

  PopupMenuButton<int> buildPopupMenuButtonDesktop(BuildContext context) {
    return PopupMenuButton<int>(
      onSelected: (int selection) {
        this._onSelectedDesktop(selection, context);
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: 0,
            child: Text("create new folder"),
          ),
          PopupMenuItem(
            value: 1,
            child: Text("create new document"),
          ),
          PopupMenuItem(
            value: 2,
            child: Text("Upload files"),
          ),
        ];
      },
      icon: Icon(
        Icons.add,
        color: this.color,
      ),
    );
  }
}
