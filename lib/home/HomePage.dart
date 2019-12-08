import 'package:django_nas_mobile/home/CreateNewButton.dart';
import 'package:django_nas_mobile/home/Row.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
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
    Future.delayed(Duration(milliseconds: 30)).then((_) async {
      NasProvider provider = Provider.of(context);
      await provider.goToNext(widget.folderID);
    });
  }

  /// build body based on currentIndex
  Widget _buildBody() {
    switch (currentIndex) {
      case 1:
        return UploadPage();

      case 2:
        return SettingPage();
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
        var data = await DataFetcher(url: folderUrl)
            .fetchOne<NasFolder>(id: provider.currentFolder.id);
        provider.currentFolder = data;
        provider.update();
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

  @override
  Widget build(BuildContext context) {
    Widget body = _buildBody();
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
      body: body,
      bottomNavigationBar: BottomNavigationBar(
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
          )
        ],
      ),
    );
  }
}
