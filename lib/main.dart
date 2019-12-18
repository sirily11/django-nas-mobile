import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:django_nas_mobile/models/SelectionProvider.dart';
import 'package:django_nas_mobile/models/SystemProvider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home/HomePage.dart';
import 'models/UploadDownloadProvider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          builder: (_) => NasProvider(),
        ),
        ChangeNotifierProvider(
          builder: (_) => UploadDownloadProvider(),
        ),
        ChangeNotifierProvider(
          builder: (_) => SystemProvider(),
        ),
        ChangeNotifierProvider(
          builder: (_) => SelectionProvider(),
        )
      ],
      child: MaterialApp(
          title: 'Flutter Demo',
          // darkTheme: ThemeData.dark(),
          theme: ThemeData(primarySwatch: Colors.blue),
          home: HomePage()),
    );
  }
}
