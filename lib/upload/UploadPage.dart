import 'package:django_nas_mobile/models/UploadProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;

class UploadPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UploadProvider uploadProvider = Provider.of(context);

    return Stack(
      children: <Widget>[
        ListView.separated(
          separatorBuilder: (ctx, index) {
            return Divider();
          },
          itemCount: uploadProvider.onlyNotUploadItem
              ? uploadProvider.items.where((i) => !i.isDone).toList().length
              : uploadProvider.items.length,
          itemBuilder: (context, index) {
            UploadItem item = uploadProvider.onlyNotUploadItem
                ? uploadProvider.items.where((i) => !i.isDone).toList()[index]
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
                    : null,
                leading: Icon(Icons.insert_drive_file),
                title: Text(p.basename(item.file.path)),
                subtitle: LinearProgressIndicator(
                  value: item.progress ?? 0,
                ),
              ),
            );
          },
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
  const TotalUploadProgress({@required Key key, this.right = 20})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    UploadProvider uploadProvider = Provider.of(context);
    final int totalNumber = uploadProvider.items.length;
    final int numberFinished =
        uploadProvider.items.where((i) => i.isDone).length;
    final double progress = uploadProvider.items
        .firstWhere((i) => !i.isDone, orElse: () => null)
        ?.progress;
    return Positioned(
      bottom: 20,
      right: this.right,
      child: Hero(
        tag: key,
        child: Container(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: <Widget>[
                  AnimatedContainer(
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
                  Text("Upload Progress: $numberFinished/$totalNumber"),
                  IconButton(
                    tooltip: !uploadProvider.onlyNotUploadItem
                        ? "Hide not upload items"
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
                      color: Theme.of(context).accentColor,
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
