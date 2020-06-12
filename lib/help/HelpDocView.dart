import 'package:django_nas_mobile/drawer/DrawerPanel.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:flutter/material.dart';
import 'package:json_screen/json_screen.dart';
import 'package:provider/provider.dart';

class HelpDocView extends StatelessWidget {
  final String path;
  final bool isRoot;

  HelpDocView({this.path, this.isRoot = false});

  Future<String> getDocs(BuildContext context) async {
    NasProvider provider = Provider.of(context, listen: false);
    var resp = await provider.networkProvider.get("${provider.baseURL}$path");
    return resp.data;
  }

  @override
  Widget build(BuildContext context) {
    NasProvider provider = Provider.of(context);
    String baseURL = "${provider.baseURL}";
    return Scaffold(
      appBar: AppBar(),
      drawer: isRoot ? DrawerPanel() : null,
      body: FutureBuilder<String>(
          future: getDocs(context),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text("${snapshot.error}"),
              );
            }
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            return JsonScreen(
              onLinkTap: (link) async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HelpDocView(
                      path: "$link",
                    ),
                  ),
                );
              },
              pages: XMLConverter(
                xml: snapshot.data,
                baseURL: baseURL,
              ).convert(),
            );
          }),
    );
  }
}
