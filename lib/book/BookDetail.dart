import 'package:django_nas_mobile/home/components/CreateNewDialog.dart';
import 'package:django_nas_mobile/home/components/UpdateDialog.dart';
import 'package:django_nas_mobile/home/views/EditorView.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/ball_pulse_header.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import 'BookEditDetail.dart';

class BookDetail extends StatefulWidget {
  final BookCollection collection;
  final List<BookCollection> collections;

  BookDetail({@required this.collection, @required this.collections});
  @override
  _BookDetailState createState() => _BookDetailState();
}

class _BookDetailState extends State<BookDetail> {
  BookCollection bookDetail;

  @override
  Widget build(BuildContext context) {
    NasProvider provider = Provider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("${bookDetail?.name ?? widget.collection.name}"),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              TextEditingController document = TextEditingController();
              showDialog(
                context: context,
                builder: (c) => CreateNewDialog<BookCollection>(
                  editingController: document,
                  title: "Document",
                  fieldName: "Document Name",
                  onSubmit: (v) async {
                    var doc = await provider.createNewDocument(
                      document.text,
                      isCollection: true,
                      collection: widget.collection,
                    );
                    setState(() {
                      bookDetail.documents.add(doc);
                    });
                  },
                ),
              );
            },
            icon: Icon(Icons.add),
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => BookEditDetail(
                    collection: bookDetail,
                  ),
                ),
              );
              await fetchDetail(provider);
            },
          )
        ],
      ),
      body: EasyRefresh(
        header: BallPulseHeader(),
        firstRefresh: true,
        onRefresh: () async {
          await fetchDetail(provider);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Card(
                    child: Container(
                      height: 170,
                      width: 150,
                      child: Center(
                        child: Text(
                            "${bookDetail?.name ?? widget.collection.name}"),
                      ),
                    ),
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  Expanded(
                    flex: 9,
                    child: Text(
                      "${bookDetail?.description ?? widget.collection.description}",
                    ),
                  )
                ],
              ),
              Divider(),
              if (bookDetail != null)
                ListView.separated(
                  separatorBuilder: (c, i) => Padding(
                    padding: const EdgeInsets.only(left: 70),
                    child: Divider(),
                  ),
                  itemCount: bookDetail.documents.length,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (c, i) {
                    var doc = bookDetail.documents[i];
                    return Slidable(
                      actionPane: SlidableDrawerActionPane(),
                      secondaryActions: <Widget>[
                        IconSlideAction(
                          caption: "Delete",
                          icon: Icons.delete,
                          color: Colors.red,
                          onTap: () async {
                            await provider.deleteDocument(doc);
                            setState(() {
                              bookDetail.documents.removeWhere(
                                (d) => d.id == doc.id,
                              );
                            });
                          },
                        ),
                        IconSlideAction(
                          caption: "Edit",
                          icon: Icons.edit,
                          color: Colors.blue,
                          onTap: () async {
                            TextEditingController controller =
                                TextEditingController(text: doc.name);
                            showDialog(
                              context: context,
                              builder: (c) => UpdateDialog<BookCollection>(
                                editingController: controller,
                                title: "Document",
                                fieldName: "Document Name",
                                selectionFieldName: "Book",
                                defualtSelection: Selection(
                                  title: widget.collection.name,
                                  value: widget.collection,
                                ),
                                selections: widget.collections
                                    .map(
                                      (s) => Selection(title: s.name, value: s),
                                    )
                                    .toList(),
                                onSubmit: (v) async {
                                  await provider.updateDocumentCollection(
                                      doc.id, v.value);
                                  await fetchDetail(provider);
                                },
                              ),
                            );
                          },
                        )
                      ],
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => EditorView(
                                id: doc.id,
                                name: doc.name,
                              ),
                            ),
                          );
                        },
                        leading: Icon(Icons.book),
                        title: Text("${doc.name}"),
                        trailing: Icon(Icons.more_horiz),
                      ),
                    );
                  },
                )
            ],
          ),
        ),
      ),
    );
  }

  Future fetchDetail(NasProvider provider) async {
    var result =
        await provider.fetchBookCollectionDetail(id: widget.collection.id);
    setState(() {
      bookDetail = result;
    });
  }
}
