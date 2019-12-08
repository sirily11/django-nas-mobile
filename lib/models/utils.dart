import 'dart:convert';
import 'dart:math';

import 'package:zefyr/zefyr.dart';

/// get string representation of size
/// [size] size of file in bytes
/// if size >= 1024, then returns in kb
/// if size >= 1024kb, then returns in MB
/// if size >= 1024 mb, then returns in GB
/// if size >= 1024 gb, then returns in TB
/// if size >= 1024 TB, then returns in PB
String getSize(double size) {
  if (size >= pow(1024, 1)) {
    String sizeStr = (size / pow(1024, 1)).toStringAsFixed(2);
    return "$sizeStr KB";
  } else if (size >= pow(1024, 2)) {
    String sizeStr = (size / pow(1024, 2)).toStringAsFixed(2);
    return "$sizeStr MB";
  } else if (size >= pow(1024, 3)) {
    String sizeStr = (size / pow(1024, 3)).toStringAsFixed(2);
    return "$sizeStr GB";
  } else if (size >= pow(1024, 4)) {
    String sizeStr = (size / pow(1024, 4)).toStringAsFixed(2);
    return "$sizeStr TB";
  } else if (size >= pow(1024, 5)) {
    String sizeStr = (size / pow(1024, 5)).toStringAsFixed(2);
    return "$sizeStr PB";
  }
  return "$size bytes";
}

/// Convert quill data from Quill  to flutter quill data
///
List<dynamic> convertFromQuill(List<dynamic> data) {
  for (var entry in data) {
    if (entry.containsKey("attributes")) {
      Map<String, dynamic> attibutes = entry['attributes'];
      Map<String, dynamic> copy = Map.from(entry['attributes']);
      attibutes.forEach((k, v) {
        switch (k) {
          case "italic":
            copy['i'] = v;
            break;
          case "bold":
            copy['b'] = v;
            break;
          case "link":
            copy['a'] = v;

            break;
          case "header":
            copy['heading'] = v;
            break;
          case "list":
            if (v == "ordered") {
              copy['block'] = "ol";
            } else {
              copy['block'] = 'ul';
            }
            break;
          default:
            break;
        }
        copy.remove(k);
      });
      entry['attributes'] = copy;
    }
  }
  return data;
}

/// Convert Quill flutter to Quill JS
List<dynamic> convertToQuill(NotusDocument document) {
  List<dynamic> data = json.decode(json.encode(document));
  for (var entry in data) {
    if (entry.containsKey("attributes")) {
      Map<String, dynamic> attibutes = entry['attributes'];
      Map<String, dynamic> copy = Map.from(entry['attributes']);
      attibutes.forEach((k, v) {
        switch (k) {
          case "i":
            copy['italic'] = v;
            break;
          case "b":
            copy['bold'] = v;
            break;
          case "a":
            copy['link'] = v;
            break;
          case "heading":
            copy['header'] = v;
            break;

          case "block":
            if (v == "ol") {
              copy['list'] = "ordered";
            } else if (v == "ul") {
              copy['list'] = 'bullet';
            }
            break;
            break;
        }
      });
      entry['attributes'] = copy;
    }
  }
  return data;
}