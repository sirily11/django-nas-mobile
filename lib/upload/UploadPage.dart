import 'package:django_nas_mobile/models/UploadDownloadProvider.dart';
import 'package:django_nas_mobile/models/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;

class UploadPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UploadDownloadProvider uploadProvider = Provider.of(context);

    return Stack(
      children: <Widget>[
        Scrollbar(
          child: uploadProvider.items.length == 0
              ? Container()
              : ScrollablePositionedList.separated(
                  itemScrollController: uploadProvider.scrollController,
                  separatorBuilder: (ctx, index) {
                    return Divider();
                  },
                  itemCount: uploadProvider.onlyNotUploadItem
                      ? uploadProvider.items
                          .where((i) => !i.isDone)
                          .toList()
                          .length
                      : uploadProvider.items.length,
                  itemBuilder: (context, index) {
                    UploadDownloadItem item = uploadProvider.onlyNotUploadItem
                        ? uploadProvider.items
                            .where((i) => !i.isDone)
                            .toList()[index]
                        : uploadProvider.items[index];
                    return Slidable(
                      actionPane: SlidableDrawerActionPane(),
                      secondaryActions: <Widget>[
                        IconSlideAction(
                          onTap: () async {
                            uploadProvider.removeItem(item);
                          },
                          icon: Icons.delete,
                          caption: "Delete",
                          color: Colors.red,
                        ),
                      ],
                      child: ListTile(
                        trailing: item.isDone
                            ? Icon(
                                Icons.done,
                                color: Colors.green,
                              )
                            : Icon(
                                Icons.clear,
                                color: Theme.of(context).disabledColor,
                              ),
                        leading: Stack(
                          children: <Widget>[
                            CircularProgressIndicator(
                              value: item.progress ?? 0,
                            ),
                            Positioned.fill(
                              child: Align(
                                child: Text(
                                  "${((item.progress ?? 0) * 100).toStringAsFixed(0)}%",
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                            )
                          ],
                        ),
                        title: Text(p.basename(item.file.path)),
                        subtitle: Text(
                            "${getSize(item.current.toDouble())}/${getSize(item?.total?.toDouble())}"),
                      ),
                    );
                  },
                ),
        ),
        TotalUploadProgress(
          key: Key("uploadpage-progess"),
        )
      ],
    );
  }
}

class TotalUploadProgress extends StatelessWidget {
  final double right;
  final double bottom;
  final double width;
  final double elevation;
  const TotalUploadProgress(
      {@required Key key,
      this.right = 20,
      this.bottom = 20,
      this.width,
      this.elevation = 1.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    UploadDownloadProvider uploadProvider = Provider.of(context);
    final int totalNumber = uploadProvider.items.length;
    final int numberFinished =
        uploadProvider.items.where((i) => i.isDone).length;
    final double progress = uploadProvider.items
        .firstWhere((i) => !i.isDone, orElse: () => null)
        ?.progress;

    return Positioned(
      bottom: this.bottom,
      width: this.width,
      right: this.right,
      child: Hero(
        tag: key,
        child: Container(
          child: Card(
            elevation: this.elevation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 10),
                    child: progress != null
                        ? Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Container(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(
                                value: progress ?? 0,
                                strokeWidth: 3,
                              ),
                            ),
                          )
                        : Container(),
                  ),
                  Text("Transfer Progress: $numberFinished/$totalNumber"),
                  IconButton(
                    tooltip: !uploadProvider.onlyNotUploadItem
                        ? "Hide not in progress items"
                        : "Show all items",
                    onPressed: () {
                      uploadProvider.onlyNotUploadItem =
                          !uploadProvider.onlyNotUploadItem;
                      //TODO: change this by adding private variable
                      uploadProvider.notifyListeners();
                    },
                    icon: Icon(
                      !uploadProvider.onlyNotUploadItem
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  IconButton(
                    tooltip: "Pause Upload",
                    onPressed: () {
                      uploadProvider.pause = !uploadProvider.pause;
                    },
                    icon: Icon(
                      uploadProvider.pause ? Icons.play_arrow : Icons.pause,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  IconButton(
                    tooltip: "Clear All Finished",
                    icon: Icon(
                      Icons.clear,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      uploadProvider.removeAllItem();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
