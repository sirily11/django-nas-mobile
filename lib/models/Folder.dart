/// Root Folder
class RootFolder {
  int id;
  String name;
  String description;
  int user;
  List<NasFile> files;
  List<NasFolder> folders;
  List<Parent> parents;
  List<NasDocument> documents;
  double totalSize;

  RootFolder({
    this.id,
    this.name,
    this.description,
    this.files,
    this.folders,
    this.parents,
    this.documents,
    this.totalSize,
  });

  factory RootFolder.fromJson(Map<String, dynamic> json) => RootFolder(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        files:
            List<NasFile>.from(json["files"].map((x) => NasFile.fromJson(x))),
        folders: List<NasFolder>.from(
            json["folders"].map((x) => NasFolder.fromJson(x))),
        documents: List<NasDocument>.from(
            json["documents"].map((x) => NasDocument.fromJson(x))),
        totalSize: json["total_size"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "user": user,
        "files": List<dynamic>.from(files.map((x) => x)),
        "folders": List<dynamic>.from(folders.map((x) => x.toJson())),
        "parents": List<dynamic>.from(parents.map((x) => x.toJson())),
        "documents": List<dynamic>.from(documents.map((x) => x)),
        "total_size": totalSize,
      };
}

class NasFolder {
  int id;
  DateTime createdAt;
  String name;
  int parent;
  String description;
  int user;
  DateTime modifiedAt;
  List<NasFile> files;
  List<NasFolder> folders;
  List<Parent> parents;
  List<NasDocument> documents;
  double totalSize;

  NasFolder({
    this.id,
    this.createdAt,
    this.name,
    this.parent,
    this.description,
    this.user,
    this.modifiedAt,
    this.files,
    this.folders,
    this.parents,
    this.documents,
    this.totalSize,
  });

  factory NasFolder.fromJson(Map<String, dynamic> json) => NasFolder(
        id: json["id"],
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : null,
        name: json["name"],
        parent: json["parent"],
        description: json["description"],
        user: json["user"],
        modifiedAt: json["modified_at"] != null
            ? DateTime.parse(json["modified_at"])
            : null,
        files: List<NasFile>.from(
            json["files"]?.map((x) => NasFile.fromJson(x)) ?? []),
        folders: List<NasFolder>.from(
            json["folders"]?.map((x) => NasFolder.fromJson(x)) ?? []),
        documents: List<NasDocument>.from(
            json["documents"]?.map((x) => NasDocument.fromJson(x)) ?? []),
        parents: List<Parent>.from(
            json["parents"]?.map((x) => Parent.fromJson(x)) ?? []),
        totalSize: json["total_size"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "parent": parent,
      };
}

class Parent {
  String name;
  int id;

  Parent({
    this.name,
    this.id,
  });

  factory Parent.fromJson(Map<String, dynamic> json) => Parent(
        name: json["name"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
      };
}

class NasDocument {
  int id;
  DateTime createdAt;
  String name;
  String description;
  double size;
  DateTime modifiedAt;
  int parent;
  String content;

  NasDocument({
    this.id,
    this.createdAt,
    this.name,
    this.description,
    this.size,
    this.modifiedAt,
    this.parent,
    this.content,
  });

  factory NasDocument.fromJson(Map<String, dynamic> json) => NasDocument(
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
        name: json["name"],
        description: json["description"],
        size: json["size"],
        modifiedAt: DateTime.parse(json["modified_at"]),
        parent: json["parent"],
        content: json["content"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt.toIso8601String(),
        "name": name,
        "description": description,
        "size": size,
        "modified_at": modifiedAt.toIso8601String(),
        "parent": parent,
        "content": content,
      };
}

class NasFile {
  int id;
  DateTime createdAt;
  int parent;
  String description;
  dynamic user;
  double size;
  DateTime modifiedAt;
  String file;
  String objectType;
  String filename;

  NasFile({
    this.id,
    this.createdAt,
    this.parent,
    this.description,
    this.user,
    this.size,
    this.modifiedAt,
    this.file,
    this.objectType,
    this.filename,
  });

  factory NasFile.fromJson(Map<String, dynamic> json) => NasFile(
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
        parent: json["parent"],
        description: json["description"],
        user: json["user"],
        size: json["size"].toDouble(),
        modifiedAt: DateTime.parse(json["modified_at"]),
        file: json["file"],
        objectType: json["object_type"],
        filename: json["filename"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt.toIso8601String(),
        "parent": parent,
        "description": description,
        "user": user,
        "size": size,
        "modified_at": modifiedAt.toIso8601String(),
        "file": file,
        "object_type": objectType,
        "filename": filename,
      };
}
