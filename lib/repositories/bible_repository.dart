import 'package:sqflite/sqflite.dart';

import '../core/database/database_helper.dart';
import '../models/book_model.dart';
import '../models/verse_model.dart';

abstract interface class BibleDataSource {
  Future<List<BookModel>> getBooks();

  Future<List<VerseModel>> searchVerses(String query);

  Future<List<VerseModel>> getChapterVerses({
    required int bookId,
    required int chapter,
  });
}

class BibleRepository implements BibleDataSource {
  final DatabaseHelper _databaseHelper;
  Future<List<VerseModel>>? _allVersesFuture;

  BibleRepository({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  static const _ignoredSearchWords = {
    'a',
    'al',
    'algo',
    'con',
    'como',
    'cual',
    'de',
    'del',
    'el',
    'en',
    'es',
    'la',
    'las',
    'lo',
    'los',
    'me',
    'mi',
    'o',
    'para',
    'por',
    'que',
    'se',
    'su',
    'un',
    'una',
    'y',
  };

  static const _searchSynonyms = {
    'barca': 'arca',
    'barco': 'arca',
    'embarcacion': 'arca',
  };

  static String _normalizeSearchText(String text) {
    const accentedCharacters = 'áéíóúüñ';
    const plainCharacters = 'aeiouun';
    var normalized = text.toLowerCase();
    for (var index = 0; index < accentedCharacters.length; index++) {
      normalized = normalized.replaceAll(
        accentedCharacters[index],
        plainCharacters[index],
      );
    }
    return normalized.replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
  }

  @override
  Future<List<VerseModel>> searchVerses(String query) async {
    final keywords = _normalizeSearchText(query)
        .split(' ')
        .where((word) => word.length > 1 && !_ignoredSearchWords.contains(word))
        .toSet();
    if (keywords.isEmpty) return const [];

    final expandedKeywords = <String>{...keywords};
    for (final keyword in keywords) {
      final synonym = _searchSynonyms[keyword];
      if (synonym != null) expandedKeywords.add(synonym);
    }

    final allVerses = await (_allVersesFuture ??= _loadAllVerses());
    final rankedVerses = <({VerseModel verse, int score})>[];
    for (final verse in allVerses) {
      final normalizedText = _normalizeSearchText(verse.text);
      final words = normalizedText.split(' ').toSet();
      final score = expandedKeywords.where(words.contains).length;
      if (score > 0) rankedVerses.add((verse: verse, score: score));
    }

    rankedVerses.sort((left, right) {
      final byScore = right.score.compareTo(left.score);
      if (byScore != 0) return byScore;
      final byBook = left.verse.bookName.compareTo(right.verse.bookName);
      if (byBook != 0) return byBook;
      final byChapter = left.verse.chapter.compareTo(right.verse.chapter);
      return byChapter != 0
          ? byChapter
          : left.verse.verse.compareTo(right.verse.verse);
    });

    return rankedVerses
        .take(5)
        .map((result) => result.verse)
        .toList(growable: false);
  }

  Future<List<VerseModel>> _loadAllVerses() async {
    final database = await _databaseHelper.database;
    final rows = await database.rawQuery('''
      SELECT
        b.modern_name AS book_name,
        v.chapter,
        v.verse,
        v.text
      FROM verses v
      INNER JOIN books b ON b.id = v.book_id
    ''');
    return rows.map(VerseModel.fromMap).toList(growable: false);
  }

  @override
  Future<List<BookModel>> getBooks() async {
    final Database database = await _databaseHelper.database;
    final rows = await database.rawQuery('''
      SELECT
        b.id,
        b.name,
        b.modern_name,
        b.new_testament,
        COUNT(DISTINCT v.chapter) AS chapters_count
      FROM books b
      LEFT JOIN verses v ON v.book_id = b.id
      GROUP BY b.id, b.name, b.modern_name, b.new_testament
      ORDER BY b.id ASC
    ''');

    return rows.map(BookModel.fromMap).toList(growable: false);
  }

  @override
  Future<List<VerseModel>> getChapterVerses({
    required int bookId,
    required int chapter,
  }) async {
    final Database database = await _databaseHelper.database;
    final rows = await database.rawQuery(
      '''
      SELECT
        b.name AS book_name,
        v.chapter,
        v.verse,
        v.text
      FROM verses v
      INNER JOIN books b ON v.book_id = b.id
      WHERE v.book_id = ? AND v.chapter = ?
      ORDER BY v.verse ASC
      ''',
      [bookId, chapter],
    );

    return rows.map(VerseModel.fromMap).toList(growable: false);
  }
}
