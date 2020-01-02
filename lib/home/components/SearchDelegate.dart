import 'dart:convert';

import 'package:django_nas_mobile/home/HomePage.dart';
import 'package:django_nas_mobile/home/components/LoadingShimmerList.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:django_nas_mobile/models/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;

class FileSearch extends SearchDelegate {
  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: theme.appBarTheme.color,
      primaryIconTheme: theme.primaryIconTheme,
      primaryColorBrightness: theme.primaryColorBrightness,
      primaryTextTheme: theme.primaryTextTheme,
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        progress: transitionAnimation,
        icon: AnimatedIcons.menu_arrow,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    NasProvider nasProvider = Provider.of(context);
    return FutureBuilder<List<NasFile>>(
      future: nasProvider.search(query),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("${snapshot.error.toString()}"),
          );
        }
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          child: !snapshot.hasData
              ? LoadingShimmerList()
              : buildList(snapshot.data),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    NasProvider nasProvider = Provider.of(context);
    var files = nasProvider.currentFolder.files
        .where(
          (f) => f.name?.toLowerCase()?.contains(query) ?? false,
        )
        .toList();

    return buildList(files);
  }

  Widget buildList(List<NasFile> files) {
    Utf8Decoder decode = Utf8Decoder();
    return ListView.builder(
      itemCount: files.length,
      itemBuilder: (context, index) {
        NasFile file = files[index];
        return ListTile(
          leading: renderMobileIcon(path: file.file, file: file, size: 100),
          title: Text("${p.basename(file.filename)}"),
          subtitle: Text(getSize(file.size)),
          trailing: IconButton(
            tooltip: "Go to folder",
            icon: Icon(Icons.folder),
            onPressed: () async {
              Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                  builder: (context) => HomePage(
                    folderID: file.parent,
                    name: p.basename(p.dirname(file.filename)),
                  ),
                ),
              );
            },
          ),
          onTap: () async {
            await onFileTap(file: file, context: context);
          },
        );
      },
    );
  }
}
