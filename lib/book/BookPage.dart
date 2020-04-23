import 'package:django_nas_mobile/book/BookCreate.dart';
import 'package:django_nas_mobile/drawer/DrawerPanel.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:django_nas_mobile/music/components/InitProgressDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/ball_pulse_header.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:provider/provider.dart';

import 'BookDetail.dart';

class BookPage extends StatefulWidget {
  @override
  _BookPageState createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  List<BookCollection> collections = [];

  @override
  Widget build(BuildContext context) {
    NasProvider provider = Provider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Books"),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => BookCreate(),
                ),
              );
              await fetch(provider);
            },
            icon: Icon(Icons.add),
          )
        ],
      ),
      drawer: DrawerPanel(),
      body: EasyRefresh(
        header: BallPulseHeader(),
        firstRefresh: true,
        firstRefreshWidget: InitLoadingProgressDialog(),
        onRefresh: () async {
          await fetch(provider);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              title: Text("Books"),
            ),
            ListTile(
              title: Text("Collections"),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "My Books",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            GridView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
              ),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: collections.length,
              itemBuilder: (c, i) {
                BookCollection bookCollection = collections[i];
                return Container(
                  height: 600,
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => BookDetail(
                            collections: collections,
                            collection: bookCollection,
                          ),
                        ),
                      );
                      await fetch(provider);
                    },
                    child: Card(
                      child: Center(
                        child: Text(
                          "${bookCollection.name}",
                          style: TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Future fetch(NasProvider provider) async {
    var result = await provider.fetchBookCollections();
    setState(() {
      collections = result;
    });
  }
}
