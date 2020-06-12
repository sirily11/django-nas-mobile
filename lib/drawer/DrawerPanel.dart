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
            title: Text("Nas"),
            onTap: () => Navigator.pushReplacementNamed(context, "/"),
          ),
          ListTile(
            title: Text("Music"),
            onTap: () => Navigator.pushReplacementNamed(context, "/music"),
          ),
          ListTile(
            title: Text("Books"),
            onTap: () => Navigator.pushReplacementNamed(context, "/books"),
          ),
          ListTile(
            title: Text("Logs"),
            onTap: () => Navigator.pushReplacementNamed(context, "/logs"),
          ),
          ListTile(
            title: Text("Help"),
            onTap: () => Navigator.pushReplacementNamed(context, "/help"),
          )
        ],
      ),
    );
  }
}
