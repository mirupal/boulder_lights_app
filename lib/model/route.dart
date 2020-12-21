import 'package:uuid/uuid.dart';
class BoardRoute {
  String guid;
  String title;
  String holds;
  String creator;
  String difficulty;
  DateTime createdAt;

  // TODO Add Author

  BoardRoute({
    this.title,
    this.holds,
    this.creator,
    this.difficulty,
    this.createdAt,
  });

  // List<BoardRoute> get fields => [this];
  factory BoardRoute.fromJson(Map<String, dynamic> json) {

    var instance = BoardRoute(
      title: json["title"],
      holds: json["holds"],
      creator: json["creator"],
      difficulty: json["difficulty"],
      // date: new DateTime(json["date"]),
      createdAt: new DateTime.now(),
    );

    instance.guid = json["guid"] == null ? Uuid().v1() : json["guid"];

    return instance;
  }

  Map<String, dynamic> toJson() => {
    "guid": this.guid,
    "title": this.title,
    "holds": this.holds,
    "creator": this.creator,
    "difficulty": this.difficulty,
    "createdAt": this.createdAt.toString(),
  };
}
