import 'package:flutter/material.dart';

class LyricsView extends StatelessWidget {
  final String lyrics;
  LyricsView({@required this.lyrics});

  @override
  Widget build(BuildContext context) {
    List<String> lines = lyrics.split("\n");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.close),
        ),
      ),
      body: Scrollbar(
          child: ListView.builder(
        itemCount: lines.length,
        itemBuilder: (c, i) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SelectableText(
              "${lines[i]}",
              style: TextStyle(fontSize: 20),
            ),
          );
        },
      )),
    );
  }
}
