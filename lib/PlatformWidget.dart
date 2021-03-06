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
        if (Platform.isMacOS) {
          return desktop;
        }

        if (constrains.maxWidth > 760) {
          return largeScreen ?? desktop;
        }

        return mobile;
      },
    );
  }
}
