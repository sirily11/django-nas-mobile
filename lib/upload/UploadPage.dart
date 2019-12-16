import 'package:django_nas_mobile/models/UploadProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;

class UploadPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UploadProvider uploadProvider = Provider.of(context);
    final int totalNumber = uploadProvider.items.length;
    final int numberFinished =
        uploadProvider.items.where((i) => i.isDone).length;

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
        Positioned(
          bottom: 20,
          right: 10,
          child: Container(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: <Widget>[
                    Text("Upload Progress: $numberFinished/$totalNumber"),
                    Switch(
                      value: uploadProvider.onlyNotUploadItem,
                      onChanged: (value) {
                        uploadProvider.onlyNotUploadItem = value;
                        //TODO: change this by adding private variable
                        uploadProvider.notifyListeners();
                      },
                    ),
                    IconButton(
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
        )
      ],
    );
  }
}
