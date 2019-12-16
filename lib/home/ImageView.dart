import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

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
      body: Center(
        child: PhotoView(
          imageProvider: NetworkImage(this.url),
        ),
      ),
    );
  }
}
