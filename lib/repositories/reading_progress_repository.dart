import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingProgress {
  final int bookId;
  final String bookName;
  final int chapter;
  final int chaptersCount;
  final int? verseNumber;

  const ReadingProgress({
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.chaptersCount,
    this.verseNumber,
  });

  String get reference =>
      '$bookName $chapter${verseNumber == null ? '' : ':$verseNumber'}';

  Map<String, Object?> toJson() => {
    'bookId': bookId,
    'bookName': bookName,
    'chapter': chapter,
    'chaptersCount': chaptersCount,
    'verseNumber': verseNumber,
  };

  static ReadingProgress? decode(String? value) {
    if (value == null) return null;
    try {
      final json = jsonDecode(value);
      if (json is! Map<String, dynamic>) return null;
      final bookId = json['bookId'];
      final bookName = json['bookName'];
      final chapter = json['chapter'];
      final chaptersCount = json['chaptersCount'];
      final verseNumber = json['verseNumber'];
      if (bookId is! int ||
          bookName is! String ||
          chapter is! int ||
          chaptersCount is! int ||
          (verseNumber != null && verseNumber is! int)) {
        return null;
      }
      return ReadingProgress(
        bookId: bookId,
        bookName: bookName,
        chapter: chapter,
        chaptersCount: chaptersCount,
        verseNumber: verseNumber as int?,
      );
    } on FormatException {
      return null;
    }
  }
}

class ReadingProgressRepository {
  ReadingProgressRepository();

  static final instance = ReadingProgressRepository();
  static const _storageKey = 'reading_progress.last_position';

  final ValueNotifier<ReadingProgress?> current = ValueNotifier(null);

  Future<ReadingProgress?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final rawProgress = preferences.getString(_storageKey);
    final progress = ReadingProgress.decode(rawProgress);
    if (rawProgress != null && progress == null) {
      await preferences.remove(_storageKey);
    }
    current.value = progress;
    return progress;
  }

  Future<void> save(ReadingProgress progress) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _storageKey,
      jsonEncode(progress.toJson()),
    );
    if (saved) current.value = progress;
  }
}
