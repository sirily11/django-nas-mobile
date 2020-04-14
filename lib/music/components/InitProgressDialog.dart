import 'package:flutter/material.dart';

class InitLoadingProgressDialog extends StatelessWidget {
  const InitLoadingProgressDialog({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 150,
        width: 150,
        child: Card(
          child: Center(
            child: Container(
              width: 100,
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  Text("Loading")
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
