class BoardRoute {
  String title;
  String config;
  String creator;
  String difficulty;
  DateTime createdAt;

  // TODO Add Author

  BoardRoute({
    this.title,
    this.config,
    this.creator,
    this.difficulty,
    this.createdAt,
  });

  // List<BoardRoute> get fields => [this];
  factory BoardRoute.fromJson(Map<String, dynamic> json) => BoardRoute(
    title: json["title"],
    config: json["config"],
    // date: new DateTime(json["date"]),
    creator: json["creator"],
    difficulty: json["difficulty"],
    createdAt: new DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    "title": this.title,
    "config": this.config,
    "creator": this.creator,
    "difficulty": this.difficulty,
    "createdAt": this.createdAt.toString(),
  };
}
