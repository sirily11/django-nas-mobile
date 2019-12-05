import 'package:django_nas_mobile/home/Row.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:flutter/material.dart';

class SubDirView extends StatelessWidget {
  final int id;
  final String name;
  SubDirView({this.id, this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        // backgroundColor: Colors.transparent,
        title: Text(
          this.name,
          // style: Theme.of(context).textTheme.title,
        ),
      ),
      body: FutureBuilder<NasFolder>(
        future: DataFetcher(url: folderUrl).fetchOne(id: this.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Connection error"),
            );
          }

          int length = snapshot.data.documents.length +
              snapshot.data.folders.length +
              snapshot.data.files.length;

          /// Order is folder, document, file
          return ListView.builder(
            itemCount: length,
            itemBuilder: (ctx, index) {
              if (index >= 0 && index < snapshot.data.folders.length) {
                return FolderRow(
                  folder: snapshot.data.folders[index],
                );
              } else if (index >= snapshot.data.folders.length &&
                  index <
                      snapshot.data.documents.length +
                          snapshot.data.folders.length) {
                int prevIndex = snapshot.data.folders.length;
                return DocumentRow(
                  document: snapshot.data.documents[index - prevIndex],
                );
              } else if (index >=
                      snapshot.data.documents.length +
                          snapshot.data.folders.length &&
                  index < length) {
                int prevIndex = snapshot.data.folders.length +
                    snapshot.data.documents.length;
                return FileRow(
                  file: snapshot.data.files[index - prevIndex],
                );
              }
              return Container();
            },
          );
        },
      ),
    );
  }
}
