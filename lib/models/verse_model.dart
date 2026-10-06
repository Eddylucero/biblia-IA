class VerseModel {
  final String bookName;
  final int chapter;
  final int verse;
  final String text;

  const VerseModel({
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
  });

  factory VerseModel.fromMap(Map<String, Object?> map) {
    return VerseModel(
      bookName: map['book_name'] as String,
      chapter: map['chapter'] as int,
      verse: map['verse'] as int,
      text: map['text'] as String,
    );
  }
}
