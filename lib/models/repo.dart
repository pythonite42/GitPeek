class Repo {
  final String name;
  final String? description;
  final String? language;

  Repo({required this.name, this.description, this.language});

  factory Repo.fromJson(Map<String, dynamic> json) {
    return Repo(name: json['name'], description: json['description'], language: json['language']);
  }
}
