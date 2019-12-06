import 'dart:io';

import 'package:django_nas_mobile/home/components/CreateNewDocumentView.dart';
import 'package:django_nas_mobile/home/components/CreateNewFolderView.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:django_nas_mobile/models/UploadProvider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CreateNewButton extends StatelessWidget {
  final Color color;

  CreateNewButton({this.color});

  void _onSelected(int selection, BuildContext context) async {
    UploadProvider uploadProvider = Provider.of(context);
    NasProvider nasProvider = Provider.of(context);

    if (selection == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return CreateNewFolderView();
        }),
      );
    } else if (selection == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return CreateNewDocumentView();
        }),
      );
    } else if (selection == 2) {
      List<File> files = await FilePicker.getMultiFile();
      var data = await uploadProvider.addItems(files
          .map((f) => UploadItem(file: f, parent: nasProvider.currentFolder.id))
          .toList());
      nasProvider.currentFolder.files.addAll(data);
      nasProvider.update();
    } else if (selection == 3) {
      var image = await ImagePicker.pickImage(source: ImageSource.gallery);
      var data = await uploadProvider.addItem(
          UploadItem(file: image, parent: nasProvider.currentFolder.id));
      nasProvider.currentFolder.files.add(data);
      nasProvider.update();
    } else {
      var video = await ImagePicker.pickVideo(source: ImageSource.gallery);
      var data = await uploadProvider.addItem(
          UploadItem(file: video, parent: nasProvider.currentFolder.id));
      nasProvider.currentFolder.files.add(data);
      nasProvider.update();
    }
  }

  @override
  Widget build(BuildContext context) {
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
}
