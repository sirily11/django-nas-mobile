import 'package:django_nas_mobile/home/views/ImageDelegate.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zefyr/zefyr.dart';
import 'dart:convert';
import 'package:django_nas_mobile/models/utils.dart';

class EditorView extends StatefulWidget {
  final int id;
  final String name;

  EditorView({this.id, this.name});

  @override
  EditorViewState createState() => EditorViewState();
}

class EditorViewState extends State<EditorView> {
  /// Allows to control the editor and the document.
  ZefyrController _controller;
  GlobalKey<ScaffoldState> key = GlobalKey();
  ZefyrMode mode = ZefyrMode.view;

  /// Zefyr editor like any other input field requires a focus node.
  FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    NasProvider provider = Provider.of(context);
    // Note that the editor requires special `ZefyrScaffold` widget to be
    // one of its parents.
    return Scaffold(
      key: key,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          widget.name,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () async {
            try {
              if (mode == ZefyrMode.edit) {
                this._saveDocument();
              }
            } catch (err) {} finally {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              if (mode == ZefyrMode.edit) {
                setState(() {
                  mode = ZefyrMode.view;
                });
                await this._saveDocument();
              } else {
                setState(() {
                  mode = ZefyrMode.edit;
                });
              }
            },
            icon: mode == ZefyrMode.edit ? Icon(Icons.save) : Icon(Icons.edit),
          )
        ],
      ),
      body: FutureBuilder<NasDocument>(
          future: DataFetcher(
                  url: documentUrl,
                  baseURL: provider.baseURL,
                  networkProvider: provider.networkProvider)
              .fetchOne(id: widget.id),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("Connection error");
            } else if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }
            var jsonData = snapshot.data.content != null
                ? jsonDecode(snapshot.data.content)
                : null;
            if (_controller == null) {
              var document = jsonData != null
                  ? NotusDocument.fromJson(
                      convertFromQuill(jsonData),
                    )
                  : NotusDocument();
              _controller = ZefyrController(document);
            }

            return Stack(
              children: <Widget>[
                ZefyrScaffold(
                  child: ZefyrTheme(
                    data: ZefyrThemeData(),
                    child: ZefyrEditor(
                      imageDelegate: CustomImageDelegate(),
                      mode: mode,
                      padding: EdgeInsets.all(16),
                      controller: _controller,
                      focusNode: _focusNode,
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }

  Future<void> _saveDocument() async {
    if (_controller != null) {
      try {
        final contents = jsonEncode(convertToQuill(_controller.document));
        NasProvider provider = Provider.of(context, listen: false);
        await provider.updateDocument(contents, widget.id);
        key.currentState.showSnackBar(
          SnackBar(
            content: Text("All changes saved"),
          ),
        );
      } catch (err) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            actions: <Widget>[
              FlatButton(
                child: Text("ok"),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
            content: Text("$err"),
          ),
        );
      }
    }
  }
}
