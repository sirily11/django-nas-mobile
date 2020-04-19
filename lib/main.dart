import 'package:django_nas_mobile/book/BookPage.dart';
import 'package:django_nas_mobile/logs/LogsPage.dart';
import 'package:django_nas_mobile/models/DesktopController.dart';
import 'package:django_nas_mobile/models/MusicProvider.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:django_nas_mobile/models/SelectionProvider.dart';
import 'package:django_nas_mobile/models/SystemProvider.dart';
import 'package:django_nas_mobile/music/MusicPage.dart';
import 'package:django_nas_mobile/music/components/artist/ArtistPage.dart';
import 'package:django_nas_mobile/music/components/songs/SongsPage.dart';

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
          create: (_) => NasProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UploadDownloadProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SystemProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SelectionProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DesktopController(),
        ),
        ChangeNotifierProvider(
          create: (_) => MusicProvider(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        themeMode: ThemeMode.system,
        darkTheme: ThemeData.dark().copyWith(
            primaryColor: Colors.orange,
            appBarTheme: AppBarTheme().copyWith(color: Colors.grey[900])),
        theme:
            ThemeData(primarySwatch: Colors.blue, primaryColor: Colors.orange),
        routes: {
          '/': (c) => HomePage(),
          '/music': (c) => MusicPage(),
          '/music-artist': (c) => ArtistPage(),
          '/music-song': (c) => SongsPage(),
          '/logs': (c) => LogsPage(),
          '/books': (c) => BookPage()
        },
        initialRoute: '/',
      ),
    );
  }
}
