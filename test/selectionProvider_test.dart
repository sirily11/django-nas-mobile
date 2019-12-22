import 'package:django_nas_mobile/models/SelectionProvider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Selection provider test", () {
    SelectionProvider selectionProvider;

    setUp(() {
      selectionProvider = SelectionProvider();
      selectionProvider.currentIndex = 0;
    });

    test("Change selection", () {
      selectionProvider.currentIndex = 1;
      expect(selectionProvider.currentIndex, 1);
    });
    test("Change selection", () {
      selectionProvider.currentIndex = 0;
      expect(selectionProvider.currentIndex, 0);
    });
    test("Change selection", () {
      selectionProvider.currentIndex = -1;
      expect(selectionProvider.currentIndex, -1);
    });
  });
}
