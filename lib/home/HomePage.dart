import 'dart:io';

import 'package:django_nas_mobile/PlatformWidget.dart';
import 'package:django_nas_mobile/home/FileList.dart';
import 'package:django_nas_mobile/home/PlatformWidgets/DesktopGrid.dart';
import 'package:django_nas_mobile/home/PlatformWidgets/DesktopView.dart';
import 'package:django_nas_mobile/home/PlatformWidgets/MobileView.dart';
import 'package:django_nas_mobile/home/components/CreateNewButton.dart';
import 'package:django_nas_mobile/info/InfoPage.dart';
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
        return PlatformWidget(
          desktop: DesktopFileGrid(),
          largeScreen: DesktopFileGrid(),
          mobile: FileListWidget(),
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
        leading: widget.folderID != null
            ? IconButton(
                color: Colors.black,
                onPressed: () async {
                  await provider.backToPrev();
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios),
              )
            : null,
        actions: <Widget>[
          CreateNewButton(
            color: Colors.black,
          )
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          widget.name ?? "Django NAS",
          style: Theme.of(context).textTheme.title,
        ),
      ),
      body: body,
      bottomNavigationBar: Platform.isIOS || Platform.isAndroid
          ? BottomNavigationBar(
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
            )
          : null,
    );
  }
}
