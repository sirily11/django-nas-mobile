import 'dart:io';

import 'package:django_nas_mobile/PlatformWidget.dart';
import 'package:django_nas_mobile/home/FileList.dart';
import 'package:django_nas_mobile/home/PlatformWidgets/DesktopGrid.dart';
import 'package:django_nas_mobile/home/PlatformWidgets/DesktopView.dart';
import 'package:django_nas_mobile/home/PlatformWidgets/MobileView.dart';
import 'package:django_nas_mobile/home/components/CreateNewButton.dart';
import 'package:django_nas_mobile/home/components/SearchDelegate.dart';
import 'package:django_nas_mobile/info/InfoPage.dart';
import 'package:django_nas_mobile/models/DesktopController.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:django_nas_mobile/models/SelectionProvider.dart';
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
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 20)).then((_) async {
      NasProvider provider = Provider.of(context);
      if (provider.box == null) {
        await provider.initBox();
      }

      await provider.fetchFolder(widget.folderID);
    });
  }

  /// build body based on currentIndex
  Widget _renderBody() {
    SelectionProvider selectionProvider = Provider.of(context);

    switch (selectionProvider.currentIndex) {
      case 1:
        return UploadPage();

      case 2:
        return SettingPage();

      case 3:
        return InfoPage();
      default:
        return FutureBuilder<bool>(
            future: Future.delayed(Duration(milliseconds: 50), () => true),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              return PlatformWidget(
                desktop: DesktopFileGrid(),
                largeScreen: DesktopFileGrid(),
                mobile: FileListWidget(),
              );
            });
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
        leading: widget.folderID != null && selectionProvider.currentIndex == 0
            ? IconButton(
                color: Theme.of(context).textTheme.button.color,
                onPressed: () async {
                  DesktopController controller = Provider.of(context);
                  controller.selectedElement = null;
                  await provider.backToPrev();
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios),
              )
            : IconButton(
                color: Theme.of(context).textTheme.button.color,
                onPressed: null,
                icon: Icon(Icons.arrow_back_ios),
              ),
        actions: <Widget>[
          IconButton(
            color: Theme.of(context).textTheme.button.color,
            icon: Icon(Icons.refresh),
            onPressed: () async {
              NasProvider nasProvider = Provider.of(context);
              nasProvider.isLoading = true;
              nasProvider.refresh(nasProvider.currentFolder.id);
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
        title: Text(
          widget.name ?? "Django NAS",
          style: Theme.of(context).textTheme.title,
        ),
      ),
      body: body,
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
