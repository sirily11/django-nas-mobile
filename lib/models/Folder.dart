/// Root Folder

class BaseElement {
  int id;
  String name;
  String filename;
  BaseElement({this.id});

  factory BaseElement.fromJSON(json) => BaseElement(id: json['id']);
}

class PaginationResult<T> {
  String next;
  String previous;
  int count;
  int totalPages;
  int currentPage;
  List<T> results;

  PaginationResult({
    this.count,
    this.next,
    this.currentPage,
    this.totalPages,
    this.results,
    this.previous,
  });

  factory PaginationResult.fromJSON(
          Map<String, dynamic> json, List<T> results) =>
      PaginationResult(
        count: json['count'],
        currentPage: json['current_page'],
        totalPages: json['total_pages'],
        next: json['next'],
        previous: json['previous'],
        results: results,
      );
}

class BookCollection {
  int id;
  String name;
  String description;
  DateTime createdTime;
  List<NasDocument> documents;

  BookCollection(
      {this.id, this.name, this.description, this.createdTime, this.documents});

  factory BookCollection.fromJson(Map<String, dynamic> json) => BookCollection(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        createdTime: DateTime.parse(json["created_time"]),
        documents: json['documents'] != null
            ? (json['documents'] as List)
                .map((j) => NasDocument.fromJson(j))
                .toList()
            : [],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "created_time": createdTime.toIso8601String(),
      };
}

class Logs {
  int id;
  String title;
  DateTime time;
  String content;
  String logType;
  String sender;

  Logs({
    this.id,
    this.title,
    this.time,
    this.content,
    this.logType,
    this.sender,
  });

  factory Logs.fromJson(Map<String, dynamic> json) => Logs(
        id: json["id"],
        title: json["title"],
        time: DateTime.parse(json["time"]),
        content: json["content"],
        logType: json["log_type"],
        sender: json["sender"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "time": time.toIso8601String(),
        "content": content,
        "log_type": logType,
        "sender": sender,
      };
}

class MusicMetadata extends BaseElement {
  int id;
  String title;
  String album;
  String artist;
  String year;
  String genre;
  int track;
  String picture;
  int duration;
  int file;
  bool like;
  String albumArtist;

  MusicMetadata({
    this.id,
    this.title,
    this.album,
    this.artist,
    this.year,
    this.genre,
    this.track,
    this.picture,
    this.duration,
    this.file,
    this.like,
    this.albumArtist,
  });

  factory MusicMetadata.fromJson(Map<String, dynamic> json) => MusicMetadata(
        id: json["id"],
        title: json["title"],
        album: json["album"],
        artist: json["artist"],
        year: json["year"],
        genre: json["genre"],
        track: json["track"],
        picture: json["picture"],
        duration: json["duration"],
        file: json["file"],
        like: json["like"],
        albumArtist: json['album_artist'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "album": album,
        "artist": artist,
        "year": year,
        "genre": genre,
        "track": track,
        "picture": picture,
        "duration": duration,
        "file": file,
        "like": like,
      };
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
  BookCollection bookCollection;
  int collection;

  NasDocument({
    this.id,
    this.createdAt,
    this.name,
    this.description,
    this.size,
    this.modifiedAt,
    this.parent,
    this.content,
    this.bookCollection,
    this.collection,
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
        collection: json['collection'],
        bookCollection: json['book_collection'] != null
            ? BookCollection.fromJson(json['book_collection'])
            : null,
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
        'collection': collection,
        "book_collection": bookCollection?.toJson()
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
  MusicMetadata metadata;

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
      this.hasUploadedToCloud,
      this.metadata});

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
      metadata: json['music_metadata'] != null
          ? MusicMetadata.fromJson(json['music_metadata'])
          : null,
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
        "music_metadata": metadata.toJson(),
        "has_uploaded_to_cloud": hasUploadedToCloud
      };
}
