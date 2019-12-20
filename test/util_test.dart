import 'package:django_nas_mobile/models/DesktopController.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:django_nas_mobile/models/utils.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockNasProvider extends Mock implements NasProvider {}

class MockDesktopProvider extends Mock implements DesktopController {}

void main() {
  group("Test size converter", () {
    test("Empty", () {
      expect("Empty", getSize(0));
    });

    test("bytes test", () {
      expect("1.00 bytes", getSize(1));
      expect("1023.00 bytes", getSize(1023));
      expect("1.00 KB", getSize(1024));
    });

    test("KB test", () {
      expect("1.00 KB", getSize(1025));
      expect("1.00 MB", getSize(1024.0 * 1024));
    });

    test("GB test", () {
      expect("1.00 GB", getSize(1024.0 * 1024 * 1024));
    });

    test("TB test", () {
      expect("1.00 TB", getSize(1024.0 * 1024 * 1024 * 1024));
    });

    test("PB test", () {
      expect("1.00 PB", getSize(1024.0 * 1024 * 1024 * 1024 * 1024));
    });
  });

  group("Test on drag function", () {
    NasProvider nasProvider = MockNasProvider();
    DesktopController desktopController = DesktopController();
    BaseElement data;
    BaseElement parent = BaseElement(id: 1);
    BaseElement child = BaseElement(id: 1);

    setUp(() {
      desktopController.selectedElement = BaseElement(id: 1);
    });

    test("Drag move file", () async {
      data = NasFile();
      await onDragMoveTo(
          data: data,
          element: child,
          nasProvider: nasProvider,
          desktopController: desktopController);
      verify(nasProvider.moveFileTo(any, any)).called(1);
      expect(desktopController.selectedElement, null);
      verifyNoMoreInteractions(nasProvider);
    });

    test("Drag move folder", () async {
      data = NasFolder();
      await onDragMoveTo(
          data: data,
          element: child,
          nasProvider: nasProvider,
          desktopController: desktopController);
      verify(nasProvider.moveFolderTo(any, any)).called(1);
      expect(desktopController.selectedElement, null);
      verifyNoMoreInteractions(nasProvider);
    });

    test("Drag move document", () async {
      data = NasDocument();
      await onDragMoveTo(
          data: data,
          element: child,
          nasProvider: nasProvider,
          desktopController: desktopController);
      verify(nasProvider.moveDocumentTo(any, any)).called(1);
      expect(desktopController.selectedElement, null);
      verifyNoMoreInteractions(nasProvider);
    });

    test("Drag remove document", () async {
      data = NasDocument();
      await onDragRemove(
          data: data,
          nasProvider: nasProvider,
          desktopController: desktopController);
      verify(nasProvider.deleteDocument(any)).called(1);
      expect(desktopController.selectedElement, null);
      verifyNoMoreInteractions(nasProvider);
    });

    test("Drag remove folder", () async {
      data = NasFolder();
      await onDragRemove(
          data: data,
          nasProvider: nasProvider,
          desktopController: desktopController);
      verify(nasProvider.deleteFolder(any)).called(1);
      expect(desktopController.selectedElement, null);
      verifyNoMoreInteractions(nasProvider);
    });

    test("Drag remove file", () async {
      data = NasFile();
      await onDragRemove(
          data: data,
          nasProvider: nasProvider,
          desktopController: desktopController);
      verify(nasProvider.deleteFile(any)).called(1);
      expect(desktopController.selectedElement, null);
      verifyNoMoreInteractions(nasProvider);
    });

    test("Drag moveback document", () async {
      data = NasDocument();
      await onDragMoveBack(
          data: data,
          nasProvider: nasProvider,
          element: parent,
          desktopController: desktopController);
      verify(nasProvider.moveDocumentBack(any, any)).called(1);
      expect(desktopController.selectedElement, null);
      verifyNoMoreInteractions(nasProvider);
    });

    test("Drag moveback folder", () async {
      data = NasFolder();
      await onDragMoveBack(
          data: data,
          nasProvider: nasProvider,
          element: parent,
          desktopController: desktopController);
      verify(nasProvider.moveFolderBack(any, any)).called(1);
      expect(desktopController.selectedElement, null);
      verifyNoMoreInteractions(nasProvider);
    });

    test("Drag moveback file", () async {
      data = NasFile();
      await onDragMoveBack(
          data: data,
          nasProvider: nasProvider,
          element: parent,
          desktopController: desktopController);
      verify(nasProvider.moveFileBack(any, any)).called(1);
      expect(desktopController.selectedElement, null);
      verifyNoMoreInteractions(nasProvider);
    });
  });
}
