import 'package:django_nas_mobile/models/DesktopController.dart';
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
        ),
        ChangeNotifierProvider(
          builder: (_) => DesktopController(),
        )
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          themeMode: ThemeMode.system,
          darkTheme: ThemeData.dark().copyWith(
              primaryColor: Colors.orange,
              appBarTheme: AppBarTheme().copyWith(color: Colors.grey[900])),
          theme: ThemeData(
              primarySwatch: Colors.blue, primaryColor: Colors.orange),
          home: HomePage()),
    );
  }
}
