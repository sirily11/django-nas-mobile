import 'dart:io';

import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

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
    Future.delayed(Duration(milliseconds: 30), () {
      NasProvider provider = Provider.of(context);
      setState(() {
        controller = TextEditingController(text: provider.baseURL);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Column(
          children: <Widget>[
            TextFormField(
              autovalidate: true,
              validator: (str) {
                if (!(str.startsWith("http") | str.startsWith("https"))) {
                  return "Invalid URL";
                }
                if (str.endsWith("/")) {
                  return "Invalid URL";
                }
                return null;
              },
              controller: controller,
              decoration: InputDecoration(labelText: "Base URL"),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: RaisedButton(
                child: Text("Submit"),
                onPressed: () async {
                  try {
                    NasProvider provider = Provider.of(context);
                    await provider.setURL(controller.text);
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
