import 'dart:io';

import 'package:django_nas_mobile/home/components/ConfirmDialog.dart';
import 'package:django_nas_mobile/models/DesktopController.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:django_nas_mobile/models/SelectionProvider.dart';
import 'package:django_nas_mobile/models/UploadDownloadProvider.dart';
import 'package:django_nas_mobile/models/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DesktopToolbar extends StatelessWidget {
  final Function refresh;

  DesktopToolbar({@required this.refresh});

  @override
  Widget build(BuildContext context) {
    DesktopController desktopController = Provider.of(context);
    SelectionProvider selectionProvider = Provider.of(context);
    NasProvider nasProvider = Provider.of(context);

    bool show = desktopController.selectedElement != null &&
        selectionProvider.currentIndex == 0;

    return AnimatedPositioned(
      key: Key("a"),
      bottom: MediaQuery.of(context).size.height / 3,
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
                  child: IconButton(
                    icon: Icon(Icons.cloud_upload),
                    tooltip: "Upload To S3",
                    onPressed: () async {
                      var selectedItem = desktopController.selectedElement;
                      UploadDownloadProvider provider = Provider.of(context);
                      if (selectedItem is NasFile) {
                        await provider.uploadItemsToCloud([selectedItem],
                            basePath: nasProvider.baseURL);
                      }
                      if (selectedItem is NasFolder) {
                        var folder = await DataFetcher(
                                baseURL: nasProvider.baseURL,
                                url: folderUrl,
                                networkProvider: nasProvider.networkProvider)
                            .fetchOne<NasFolder>(id: selectedItem.id);
                        await provider.uploadItemsToCloud(folder.files,
                            basePath: nasProvider.baseURL);
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DragTarget<BaseElement>(
                    onAccept: (data) async {
                      await onDragMoveBack(
                        data: data,
                        nasProvider: nasProvider,
                        desktopController: desktopController,
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
                      showDialog(
                        context: context,
                        builder: (context) => ConfirmDialog(
                          title: "Do you want to delete?",
                          content: "You cannot undo this action",
                          onConfirm: () async {
                            await onDragRemove(
                                desktopController: desktopController,
                                data: data,
                                nasProvider: nasProvider);
                          },
                        ),
                      );
                    },
                    builder: (context, candidates, rejects) {
                      return buildIconDelete(context);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DragTarget<BaseElement>(
                    onAccept: (data) async {
                      await onDragRename(
                        nasProvider: nasProvider,
                        data: data,
                        context: context,
                        desktopController: desktopController,
                      );
                    },
                    builder: (context, candidates, rejects) {
                      return buildRename(context);
                    },
                  ),
                ),
                if (Platform.isMacOS) buildDownload(context)
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
        showDialog(
          context: context,
          builder: (c) => ConfirmDialog(
            title: "Do you want to delete this?",
            content: "You cannot undo this action",
            onConfirm: () async {
              await onDragRemove(
                data: desktopController.selectedElement,
                desktopController: desktopController,
                nasProvider: nasProvider,
              );
            },
          ),
        );
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
        await onDragMoveBack(
          data: desktopController.selectedElement,
          nasProvider: nasProvider,
          desktopController: desktopController,
          element: BaseElement(id: nasProvider.currentFolder.parent),
        );
      },
      iconSize: 30,
      icon: Icon(
        Icons.folder,
        color: Theme.of(context).unselectedWidgetColor,
      ),
    );
  }

  Widget buildRename(BuildContext context) {
    DesktopController desktopController = Provider.of(context);
    NasProvider nasProvider = Provider.of(context);

    return IconButton(
      tooltip: "Rename",
      onPressed: () async {
        await onDragRename(
            nasProvider: nasProvider,
            desktopController: desktopController,
            data: desktopController.selectedElement,
            context: context);
      },
      iconSize: 30,
      icon: Icon(
        Icons.edit,
        color: Theme.of(context).unselectedWidgetColor,
      ),
    );
  }

  Widget buildDownload(BuildContext context) {
    DesktopController desktopController = Provider.of(context);
    NasProvider nasProvider = Provider.of(context);
    UploadDownloadProvider uploadDownloadProvider = Provider.of(context);

    return IconButton(
      tooltip: "Download",
      onPressed: () async {
        await downloadFile(
          context,
          uploadDownloadProvider: uploadDownloadProvider,
          file: desktopController.selectedElement,
        );
        desktopController.selectedElement = null;
      },
      iconSize: 30,
      icon: Icon(
        Icons.file_download,
        color: Theme.of(context).unselectedWidgetColor,
      ),
    );
  }
}
