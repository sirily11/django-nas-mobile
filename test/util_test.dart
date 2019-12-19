import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:django_nas_mobile/models/utils.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockNasProvider extends Mock implements NasProvider {}

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
    BaseElement data;
    BaseElement parent = BaseElement(id: 1);
    BaseElement child = BaseElement(id: 1);

    test("Drag move file", () {
      data = NasFile();
      onDragMoveTo(data: data, element: child, nasProvider: nasProvider);
      verify(nasProvider.moveFileTo(any, any)).called(1);
      verifyNoMoreInteractions(nasProvider);
    });

    test("Drag move folder", () {
      data = NasFolder();
      onDragMoveTo(data: data, element: child, nasProvider: nasProvider);
      verify(nasProvider.moveFolderTo(any, any)).called(1);
      verifyNoMoreInteractions(nasProvider);
    });

    test("Drag move document", () {
      data = NasDocument();
      onDragMoveTo(data: data, element: child, nasProvider: nasProvider);
      verify(nasProvider.moveDocumentTo(any, any)).called(1);
      verifyNoMoreInteractions(nasProvider);
    });

    test("Drag remove document", () {
      data = NasDocument();
      onDragRemove(data: data, nasProvider: nasProvider);
      verify(nasProvider.deleteDocument(any)).called(1);
      verifyNoMoreInteractions(nasProvider);
    });

    test("Drag remove folder", () {
      data = NasFolder();
      onDragRemove(data: data, nasProvider: nasProvider);
      verify(nasProvider.deleteFolder(any)).called(1);
      verifyNoMoreInteractions(nasProvider);
    });

    test("Drag remove file", () {
      data = NasFile();
      onDragRemove(data: data, nasProvider: nasProvider);
      verify(nasProvider.deleteFile(any)).called(1);
      verifyNoMoreInteractions(nasProvider);
    });

    test("Drag moveback document", () {
      data = NasDocument();
      onDragMoveBack(data: data, nasProvider: nasProvider, element: parent);
      verify(nasProvider.moveDocumentBack(any, any)).called(1);
      verifyNoMoreInteractions(nasProvider);
    });

    test("Drag moveback folder", () {
      data = NasFolder();
      onDragMoveBack(data: data, nasProvider: nasProvider, element: parent);
      verify(nasProvider.moveFolderBack(any, any)).called(1);
      verifyNoMoreInteractions(nasProvider);
    });

    test("Drag moveback file", () {
      data = NasFile();
      onDragMoveBack(data: data, nasProvider: nasProvider, element: parent);
      verify(nasProvider.moveFileBack(any, any)).called(1);
      verifyNoMoreInteractions(nasProvider);
    });
  });
}
