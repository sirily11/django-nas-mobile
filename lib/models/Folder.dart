/// Root Folder

class BaseElement {
  int id;
  String name;
  BaseElement({this.id});
}

class NasFolder extends BaseElement {
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

class NasDocument extends BaseElement {
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
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : null,
        name: json["name"],
        description: json["description"],
        size: json["size"],
        modifiedAt: json["modified_at"] != null
            ? DateTime.parse(json["modified_at"])
            : null,
        parent: json["parent"],
        content: json["content"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt?.toIso8601String(),
        "name": name,
        "description": description,
        "size": size,
        "modified_at": modifiedAt?.toIso8601String(),
        "parent": parent,
        "content": content,
      };
}

class NasFile extends BaseElement {
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
  String transcodeFilepath;
  String cover;
  bool hasUploadedToCloud;

  NasFile(
      {this.id,
      this.createdAt,
      this.parent,
      this.description,
      this.user,
      this.size,
      this.modifiedAt,
      this.file,
      this.objectType,
      this.filename,
      this.transcodeFilepath,
      this.cover,
      this.hasUploadedToCloud});

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
      cover: json['cover'],
      transcodeFilepath: json['transcode_filepath'],
      hasUploadedToCloud: json['has_uploaded_to_cloud']);

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
        "has_uploaded_to_cloud": hasUploadedToCloud
      };
}
