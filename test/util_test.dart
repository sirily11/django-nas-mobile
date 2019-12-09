import 'package:django_nas_mobile/models/utils.dart';
import 'package:test/test.dart';

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
}
