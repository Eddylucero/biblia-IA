import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteVerse {
  final int bookId;
  final String bookName;
  final int chapter;
  final int verse;
  final String text;
  final int savedAtMilliseconds;

  const FavoriteVerse({
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
    required this.savedAtMilliseconds,
  });

  String get id => '$bookId:$chapter:$verse';
  String get reference => '$bookName $chapter:$verse';

  String get dateLabel {
    final date = DateTime.fromMillisecondsSinceEpoch(
      savedAtMilliseconds,
    ).toLocal();
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Map<String, Object?> toJson() => {
    'bookId': bookId,
    'bookName': bookName,
    'chapter': chapter,
    'verse': verse,
    'text': text,
    'savedAtMilliseconds': savedAtMilliseconds,
  };

  static FavoriteVerse? decode(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    final bookId = value['bookId'];
    final bookName = value['bookName'];
    final chapter = value['chapter'];
    final verse = value['verse'];
    final text = value['text'];
    final savedAtMilliseconds = value['savedAtMilliseconds'];
    if (bookId is! int ||
        bookName is! String ||
        chapter is! int ||
        verse is! int ||
        text is! String ||
        savedAtMilliseconds is! int) {
      return null;
    }
    return FavoriteVerse(
      bookId: bookId,
      bookName: bookName,
      chapter: chapter,
      verse: verse,
      text: text,
      savedAtMilliseconds: savedAtMilliseconds,
    );
  }
}

class FavoriteVerseRepository {
  FavoriteVerseRepository();

  static final instance = FavoriteVerseRepository();
  static const _storageKey = 'favorites.verses';

  final ValueNotifier<List<FavoriteVerse>> current = ValueNotifier(const []);

  Future<List<FavoriteVerse>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final rawFavorites = preferences.getString(_storageKey);
    if (rawFavorites == null) {
      current.value = const [];
      return current.value;
    }

    try {
      final decoded = jsonDecode(rawFavorites);
      final favorites = decoded is List
          ? decoded
                .map(FavoriteVerse.decode)
                .whereType<FavoriteVerse>()
                .toList()
          : <FavoriteVerse>[];
      current.value = List.unmodifiable(favorites);
    } on FormatException {
      await preferences.remove(_storageKey);
      current.value = const [];
    }
    return current.value;
  }

  Future<bool> toggle(FavoriteVerse verse) async {
    final favorites = await load();
    final isSaved = favorites.any((item) => item.id == verse.id);
    final updated = isSaved
        ? favorites.where((item) => item.id != verse.id).toList()
        : [...favorites, verse];
    await _save(updated);
    return !isSaved;
  }

  Future<void> remove(String id) async {
    final favorites = await load();
    await _save(favorites.where((item) => item.id != id).toList());
  }

  Future<void> _save(List<FavoriteVerse> favorites) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey,
      jsonEncode(favorites.map((item) => item.toJson()).toList()),
    );
    current.value = List.unmodifiable(favorites);
  }
}
