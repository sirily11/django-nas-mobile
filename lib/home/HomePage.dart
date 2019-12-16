import 'dart:io';

import 'package:django_nas_mobile/PlatformWidget.dart';
import 'package:django_nas_mobile/home/CreateNewButton.dart';
import 'package:django_nas_mobile/home/Row.dart';
import 'package:django_nas_mobile/info/InfoPage.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:django_nas_mobile/models/UploadProvider.dart';
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
  int currentIndex = 0;

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
  Widget _buildBody() {
    switch (currentIndex) {
      case 1:
        return UploadPage();

      case 2:
        return SettingPage();

      case 3:
        return InfoPage();
      default:
        return _buildMainBody();
    }
  }

  Widget _buildMainBody() {
    NasProvider provider = Provider.of(context);
    NasFolder currentfolder = provider.currentFolder;
    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (currentfolder == null) {
      return Container();
    }
    int length = currentfolder.documents.length +
        currentfolder.folders.length +
        currentfolder.files.length;

    return RefreshIndicator(
      onRefresh: () async {
        NasProvider provider = Provider.of(context);
        await provider.refresh(provider.currentFolder.id);
      },
      child: ListView.builder(
        itemCount: length + 1,
        itemBuilder: (ctx, index) {
          // Render previous folder
          if (index == 0) {
            return provider.currentFolder.parents.length > 0
                ? ParentFolderRow()
                : Container();
          }
          // put index back (-1)
          index = index - 1;

          if (index >= 0 && index < currentfolder.folders.length) {
            return FolderRow(
              folder: currentfolder.folders[index],
            );
          } else if (index >= currentfolder.folders.length &&
              index <
                  currentfolder.documents.length +
                      currentfolder.folders.length) {
            int prevIndex = currentfolder.folders.length;
            return DocumentRow(
              document: currentfolder.documents[index - prevIndex],
            );
          } else if (index >=
                  currentfolder.documents.length +
                      currentfolder.folders.length &&
              index < length) {
            int prevIndex =
                currentfolder.folders.length + currentfolder.documents.length;
            return FileRow(
              file: currentfolder.files[index - prevIndex],
            );
          }
          return Container();
        },
      ),
    );
  }

  Widget _buildSideBar() {
    List<IconData> icons = [
      Icons.home,
      Icons.file_upload,
      Icons.settings,
      Icons.info
    ];

    return Hero(
      tag: Key("sidebar"),
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: ["Home", "Upload", "Settings", "Info"]
              .asMap()
              .map(
                (i, t) => MapEntry(
                  i,
                  MaterialButton(
                    height: 100,
                    onPressed: () => setState(
                      () {
                        currentIndex = i;
                      },
                    ),
                    child: Column(
                      children: <Widget>[
                        Icon(
                          icons[i],
                          color: currentIndex == i
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).unselectedWidgetColor,
                        ),
                        Text(
                          t,
                          style: TextStyle(
                              color: currentIndex == i
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).unselectedWidgetColor),
                        )
                      ],
                    ),
                  ),
                ),
              )
              .values
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body = PlatformWidget(
      largeScreen: buildDesktop(),
      mobile: _buildBody(),
    );
    NasProvider provider = Provider.of(context);

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
      body: PlatformWidget(
        largeScreen: Row(
          children: <Widget>[
            Expanded(
              child: _buildSideBar(),
              flex: 1,
            ),
            Expanded(
              child: body,
              flex: 9,
            )
          ],
        ),
        mobile: body,
      ),
      bottomNavigationBar: Platform.isIOS || Platform.isAndroid
          ? BottomNavigationBar(
              unselectedItemColor: Theme.of(context).unselectedWidgetColor,
              selectedItemColor: Theme.of(context).primaryColor,
              currentIndex: currentIndex,
              onTap: (index) {
                setState(
                  () {
                    currentIndex = index;
                  },
                );
              },
              items: [
                BottomNavigationBarItem(
                  title: Text("Files"),
                  icon: Icon(Icons.insert_drive_file),
                ),
                BottomNavigationBarItem(
                  title: Text("Uploads"),
                  icon: Icon(Icons.file_upload),
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

  Widget buildDesktop() {
    UploadProvider provider = Provider.of(context);
    return Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: 20),
          child: _buildBody(),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          child: provider.items.length > 0 && currentIndex == 0
              ? TotalUploadProgress(
                  key: Key("homepage-progress"),
                  right: 40,
                )
              : Container(),
        )
      ],
    );
  }
}
