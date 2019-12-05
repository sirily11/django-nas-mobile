import 'package:django_nas_mobile/home/CreateNewButton.dart';
import 'package:django_nas_mobile/home/Row.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
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
      provider.isLoading = true;
      provider.update();
      NasFolder folder = await DataFetcher(url: folderUrl)
          .fetchOne<NasFolder>(id: widget.folderID);

      provider.currentFolder = folder;
      provider.isLoading = false;
      provider.update();
    });
  }

  Widget _buildBody() {
    switch (currentIndex) {
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

    return ListView.builder(
      itemCount: length,
      itemBuilder: (ctx, index) {
        if (index >= 0 && index < currentfolder.folders.length) {
          return FolderRow(
            folder: currentfolder.folders[index],
          );
        } else if (index >= currentfolder.folders.length &&
            index <
                currentfolder.documents.length + currentfolder.folders.length) {
          int prevIndex = currentfolder.folders.length;
          return DocumentRow(
            document: currentfolder.documents[index - prevIndex],
          );
        } else if (index >=
                currentfolder.documents.length + currentfolder.folders.length &&
            index < length) {
          int prevIndex =
              currentfolder.folders.length + currentfolder.documents.length;
          return FileRow(
            file: currentfolder.files[index - prevIndex],
          );
        }
        return Container();
      },
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
                  int parentID = provider.currentFolder.parent;
                  var data = await DataFetcher(url: folderUrl)
                      .fetchOne<NasFolder>(id: parentID);
                  provider.currentFolder = data;
                  provider.update();
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
