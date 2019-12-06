import 'package:django_nas_mobile/models/UploadProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;

class UploadPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UploadProvider uploadProvider = Provider.of(context);

    return ListView.separated(
      separatorBuilder: (ctx, index) {
        return Divider();
      },
      itemCount: uploadProvider.items.length,
      itemBuilder: (context, index) {
        var item = uploadProvider.items[index];
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
            leading: Icon(Icons.insert_drive_file),
            title: Text(p.basename(item.file.path)),
            subtitle: LinearProgressIndicator(
              value: item.progress ?? 0,
            ),
          ),
        );
      },
    );
  }
}
