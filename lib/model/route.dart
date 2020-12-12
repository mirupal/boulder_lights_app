class BoardRoute {
  String title;
  String config;
  DateTime date;

  // TODO Add Author

  BoardRoute({
    this.title,
    this.config,
    // this.date,
  });

  // List<BoardRoute> get fields => [this];
  factory BoardRoute.fromJson(Map<String, dynamic> json) => BoardRoute(
    title: json["title"],
    config: json["config"],
  );
}
