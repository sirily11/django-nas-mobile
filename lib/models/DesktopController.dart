import 'package:django_nas_mobile/models/Folder.dart';
import 'package:flutter/material.dart';

class DesktopController with ChangeNotifier {
  BaseElement _selectedElement;

  set selectedElement(BaseElement ele) {
    _selectedElement = ele;
    notifyListeners();
  }

  get selectedElement => _selectedElement;
}
