import 'dart:io';

import 'package:flutter/material.dart';

/// Build widget Based on Platform
class PlatformWidget extends StatelessWidget {
  final Widget mobile;
  final Widget largeScreen;
  final Widget desktop;

  PlatformWidget({this.desktop, this.mobile, this.largeScreen});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constrains) {
        if (Platform.isMacOS || constrains.maxWidth > 600) {
          return largeScreen;
        }
        return mobile;
      },
    );
  }
}
