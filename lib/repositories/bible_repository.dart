import 'package:sqflite/sqflite.dart';

import '../core/database/database_helper.dart';
import '../models/book_model.dart';
import '../models/verse_model.dart';

abstract interface class BibleDataSource {
  Future<List<BookModel>> getBooks();

  Future<List<VerseModel>> getChapterVerses({
    required int bookId,
    required int chapter,
  });
}

class BibleRepository implements BibleDataSource {
  final DatabaseHelper _databaseHelper;

  BibleRepository({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

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
