final String tableTravel = 'travels';

class TravelFields {
  static final List<String> values = [
    /// Add all fields
    id, name, people
  ];

  static final String id = '_id';
  static final String name = 'name';
  static final String people = 'people';
}

class Travel {
  final int? id;
  final String name;
  final int people;

  const Travel({
    this.id,
    required this.name,
    required this.people,
  });

  Travel copy({
    int? id,
    String? name,
    int? people,
  }) =>
      Travel(
        id: id ?? this.id,
        name: name ?? this.name,
        people: people ?? this.people,
      );

  static Travel fromJson(Map<String, Object?> json) => Travel(
        id: json[TravelFields.id] as int?,
        name: json[TravelFields.name] as String,
        people: json[TravelFields.people] as int,
  );

  Map<String, Object?> toJson() => {
    TravelFields.id: id,
    TravelFields.name: name,
    TravelFields.people: people,
  };
}