import 'dart:io';

import 'package:django_nas_mobile/PlatformWidget.dart';
import 'package:django_nas_mobile/drawer/DrawerPanel.dart';
import 'package:django_nas_mobile/home/FileList.dart';
import 'package:django_nas_mobile/home/PlatformWidgets/DesktopGrid.dart';
import 'package:django_nas_mobile/home/PlatformWidgets/DesktopView.dart';
import 'package:django_nas_mobile/home/PlatformWidgets/MobileView.dart';
import 'package:django_nas_mobile/home/components/CreateNewButton.dart';
import 'package:django_nas_mobile/home/components/LoadingShimmerList.dart';
import 'package:django_nas_mobile/home/components/SearchDelegate.dart';
import 'package:django_nas_mobile/info/InfoPage.dart';
import 'package:django_nas_mobile/models/DesktopController.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:django_nas_mobile/models/SelectionProvider.dart';
import 'package:django_nas_mobile/models/UploadDownloadProvider.dart';
import 'package:django_nas_mobile/models/utils.dart';
import 'package:django_nas_mobile/settings/SettingPage.dart';
import 'package:django_nas_mobile/upload/UploadPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final int folderID;
  final String name;

  HomePage({this.folderID, this.name});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  NasFolder currentFolder;

  @override
  void initState() {
    super.initState();
  }

  Future fetch() async {
    NasProvider provider = Provider.of(context, listen: false);
    if (provider.box == null) {
      await provider.initBox();
    }
    var folder = await provider.fetchFolder(widget.folderID);
    setState(() {
      currentFolder = folder;
    });
  }

  /// build body based on currentIndex
  Widget _renderBody() {
    SelectionProvider selectionProvider = Provider.of(context, listen: false);

    switch (selectionProvider.currentIndex) {
      case 1:
        return UploadPage();

      case 2:
        return SettingPage();

      case 3:
        return InfoPage();
      default:
        return PlatformWidget(
          desktop: DesktopFileGrid(),
          largeScreen: DesktopFileGrid(),
          mobile: FileListWidget(
            refresh: this.fetch,
            currentFolder: currentFolder,
          ),
        );
    }
  }

  Widget buildDownloadAll(BuildContext context) {
    // DesktopController desktopController = Provider.of(context);
    NasProvider nasProvider = Provider.of(context, listen: false);
    UploadDownloadProvider uploadDownloadProvider =
        Provider.of(context, listen: false);

    return IconButton(
      tooltip: "Download All",
      onPressed: () async {
        await downloadFiles(context,
            files: nasProvider.currentFolder.files,
            uploadDownloadProvider: uploadDownloadProvider);
      },
      iconSize: 30,
      icon: Icon(
        Icons.cloud_download,
        color: Theme.of(context).unselectedWidgetColor,
      ),
    );
  }

  Widget _renderReturnActionButton() {
    NasProvider provider = Provider.of(context);

    if (MediaQuery.of(context).size.width > 760 || Platform.isMacOS) {
      if (provider?.currentFolder == null ||
          provider.currentFolder.parents.length == 0) {
        return null;
      }
      return BackButton(
        key: Key("back button"),
        color: Theme.of(context).textTheme.button.color,
        onPressed: () async {
          DesktopController controller = Provider.of(context, listen: false);
          controller.selectedElement = null;
          await provider.backToPrev();
        },
      );
    } else {
      if (!Navigator.canPop(context)) {
        return null;
      }
      return BackButton(
        key: Key("back button"),
        color: Theme.of(context).textTheme.button.color,
        onPressed: () async {
          DesktopController controller = Provider.of(context, listen: false);
          controller.selectedElement = null;
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
            await provider.backToPrev();
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body = PlatformWidget(
      desktop: DesktopView(
        body: _renderBody(),
      ),
      mobile: MobileView(
        body: _renderBody(),
      ),
    );
    NasProvider provider = Provider.of(context);
    SelectionProvider selectionProvider = Provider.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: selectionProvider.currentIndex == 0
            ? _renderReturnActionButton()
            : IconButton(
                color: Theme.of(context).textTheme.button.color,
                onPressed: null,
                icon: Icon(Icons.arrow_back_ios),
              ),
        actions: <Widget>[
          if (Platform.isMacOS) buildDownloadAll(context),
          IconButton(
            color: Theme.of(context).textTheme.button.color,
            icon: Icon(Icons.refresh),
            onPressed: () async {
              if (Platform.isMacOS) {
                await provider.refresh(provider.currentFolder.id);
              } else {
                await this.fetch();
              }
            },
          ),
          IconButton(
            color: Theme.of(context).textTheme.button.color,
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: FileSearch());
            },
          ),
          CreateNewButton(
            color: Theme.of(context).textTheme.button.color,
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: PlatformWidget(
          desktop: Text(
            provider?.currentFolder?.name ?? "Django NAS",
          ),
          mobile: Text(
            widget.name ?? "Django NAS",
          ),
        ),
      ),
      body: body,
      drawer: DrawerPanel(),
      bottomNavigationBar: PlatformWidget(
        desktop: Container(
          height: 0,
        ),
        mobile: MobileButtonNavigationBar(),
        largeScreen: Container(
          height: 0,
        ),
      ),
    );
  }
}

class MobileButtonNavigationBar extends StatelessWidget {
  const MobileButtonNavigationBar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SelectionProvider selectionProvider = Provider.of(context);

    return BottomNavigationBar(
      unselectedItemColor: Theme.of(context).unselectedWidgetColor,
      selectedItemColor: Theme.of(context).primaryColor,
      currentIndex: selectionProvider.currentIndex,
      onTap: (index) {
        selectionProvider.currentIndex = index;
      },
      items: [
        BottomNavigationBarItem(
          title: Text("Files"),
          icon: Icon(Icons.insert_drive_file),
        ),
        BottomNavigationBarItem(
          title: Text("Transfer"),
          icon: Icon(Icons.queue),
        ),
        BottomNavigationBarItem(
          title: Text("Settings"),
          icon: Icon(Icons.settings),
        ),
        BottomNavigationBarItem(
          title: Text("Info"),
          icon: Icon(Icons.info),
        )
      ],
    );
  }
}
