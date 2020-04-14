import 'package:flutter/material.dart';

class DrawerPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            child: Center(child: Text("Open App")),
          ),
          ListTile(
            title: Text("Home"),
            onTap: () => Navigator.pushReplacementNamed(context, "/"),
          ),
          ListTile(
            title: Text("Music"),
            onTap: () => Navigator.pushReplacementNamed(context, "/music"),
          )
        ],
      ),
    );
  }
}
