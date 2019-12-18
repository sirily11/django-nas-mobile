import 'package:flutter/material.dart';

/// Render page based on the selection
/// On [mobile], this will be the bottom navigation bar
/// On [Desktop] or [Large Screen], this will be sidebar
class SelectionProvider with ChangeNotifier {
  int _currentIndex = 0;

  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  int get currentIndex => _currentIndex;
}
