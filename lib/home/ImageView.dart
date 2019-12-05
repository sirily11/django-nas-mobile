import 'package:flutter/material.dart';

class ImageView extends StatelessWidget {
  final String name;
  final String url;

  ImageView({this.name, this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.name),
      ),
      body: Image.network(this.url),
    );
  }
}
