import 'package:django_nas_mobile/models/UploadProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UploadPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UploadProvider uploadProvider = Provider.of(context);

    return ListView.builder(
      itemCount: uploadProvider.items.length,
      itemBuilder: (context, index) {},
    );
  }
}
