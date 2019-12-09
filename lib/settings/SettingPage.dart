import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        controller = TextEditingController(text: prefs.getString("url"));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    NasProvider provider = Provider.of(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Column(
          children: <Widget>[
            TextField(
              controller: controller,
              decoration: InputDecoration(labelText: "Base URL"),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: RaisedButton(
                child: Text("Submit"),
                onPressed: () async {
                  try {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString("url", controller.text);
                    NasProvider provider = Provider.of(context);
                    var data =
                        await DataFetcher(url: folderUrl).fetchOne<NasFolder>();
                    provider.currentFolder = data;
                    provider.isLoading = false;
                    provider.update();
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              content: Text("Server set"),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text("ok"),
                                  onPressed: () => Navigator.pop(context),
                                )
                              ],
                            ));
                  } catch (err) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        content: Text("$err"),
                        actions: <Widget>[
                          FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("OK"),
                          )
                        ],
                      ),
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
