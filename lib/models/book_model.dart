class BookModel {
  final int id;
  final String name;
  final String modernName;
  final bool isNewTestament;
  final int chaptersCount;

  const BookModel({
    required this.id,
    required this.name,
    required this.modernName,
    required this.isNewTestament,
    required this.chaptersCount,
  });

  factory BookModel.fromMap(Map<String, Object?> map) {
    return BookModel(
      id: map['id'] as int,
      name: map['name'] as String,
      modernName: map['modern_name'] as String,
      isNewTestament: (map['new_testament'] as int) == 1,
      chaptersCount: map['chapters_count'] as int,
    );
  }
}
