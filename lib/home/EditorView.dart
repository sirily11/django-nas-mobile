import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:zefyr/zefyr.dart';
import 'dart:convert';

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

  /// Zefyr editor like any other input field requires a focus node.
  FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    // Note that the editor requires special `ZefyrScaffold` widget to be
    // one of its parents.
    return Scaffold(
      key: key,
      appBar: AppBar(
        title: Text(widget.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () async {
            try {
              await this._saveDocument();
            } catch (err) {} finally {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              await this._saveDocument();
            },
            icon: Icon(Icons.save),
          )
        ],
      ),
      body: FutureBuilder<NasDocument>(
          future: DataFetcher(url: documentUrl).fetchOne(id: widget.id),
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
              _controller = jsonData != null
                  ? ZefyrController(
                      NotusDocument.fromJson(
                        _convertFromQuil(jsonData),
                      ),
                    )
                  : ZefyrController(
                      NotusDocument(),
                    );
            }

            return ZefyrScaffold(
              child: ZefyrEditor(
                padding: EdgeInsets.all(16),
                controller: _controller,
                focusNode: _focusNode,
              ),
            );
          }),
    );
  }

  List<dynamic> _convertToQuill() {
    List<dynamic> data = json.decode(json.encode(_controller.document));
    for (var entry in data) {
      if (entry.containsKey("attributes")) {
        Map<String, dynamic> attibutes = entry['attributes'];
        Map<String, dynamic> copy = Map.from(entry['attributes']);
        attibutes.forEach((k, v) {
          switch (k) {
            case "i":
              copy['italic'] = v;
              break;
            case "b":
              copy['bold'] = v;
              break;
            case "a":
              copy['link'] = v;
              break;
            case "heading":
              copy['header'] = v;
              break;

            case "block":
              if (v == "ol") {
                copy['list'] = "ordered";
              } else if (v == "ul") {
                copy['list'] = 'bullet';
              }
              break;
              break;
          }
        });
        entry['attributes'] = copy;
      }
    }
    return data;
  }

  List<dynamic> _convertFromQuil(List<dynamic> data) {
    for (var entry in data) {
      if (entry.containsKey("attributes")) {
        Map<String, dynamic> attibutes = entry['attributes'];
        Map<String, dynamic> copy = Map.from(entry['attributes']);
        attibutes.forEach((k, v) {
          switch (k) {
            case "italic":
              copy['i'] = v;
              break;
            case "bold":
              copy['b'] = v;
              break;
            case "link":
              copy['a'] = v;

              break;
            case "header":
              copy['heading'] = v;
              break;
            case "list":
              if (v == "ordered") {
                copy['block'] = "ol";
              } else {
                copy['block'] = 'ul';
              }
              break;
            default:
              break;
          }
          copy.remove(k);
        });
        entry['attributes'] = copy;
      }
    }
    return data;
  }

  Future<void> _saveDocument() async {
    if (_controller != null) {
      try {
        final contents = jsonEncode(_convertToQuill());
        await DataFetcher(url: documentUrl)
            .update<NasDocument>(widget.id, {"content": contents});
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
