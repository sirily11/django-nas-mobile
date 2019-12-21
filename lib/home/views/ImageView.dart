import 'dart:async';

import 'package:django_nas_mobile/models/Folder.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:ui' as ui;

class ImageView extends StatelessWidget {
  final String name;
  final String url;
  final NasFile nasFile;

  ImageView({this.name, this.url, this.nasFile});

  Future<ui.Image> _getImage() {
    Completer<ui.Image> completer = new Completer<ui.Image>();
    new NetworkImage('https://i.stack.imgur.com/lkd0a.png')
        .resolve(new ImageConfiguration())
        .addListener(
      new ImageStreamListener((ImageInfo image, bool _) {
        completer.complete(image.image);
      }),
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.name),
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: PhotoView(
              imageProvider: NetworkImage(this.url),
            ),
          ),
          if (nasFile != null)
            FutureBuilder<ui.Image>(
                future: _getImage(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }

                  return Positioned(
                    bottom: 10,
                    right: 10,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("Name: $name"),
                            // Text(
                            //     "Size: ${snapshot.data.height}x${snapshot.data.width}"),
                            Text(
                                "Date: ${nasFile.createdAt.year}/${nasFile.createdAt.month}/${nasFile.createdAt.day}")
                          ],
                        ),
                      ),
                    ),
                  );
                }),
        ],
      ),
    );
  }
}
