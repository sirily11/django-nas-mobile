import 'package:flutter/material.dart';

class LyricsView extends StatelessWidget {
  final String lyrics;
  LyricsView({@required this.lyrics});

  @override
  Widget build(BuildContext context) {
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              "$lyrics",
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}
