import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/verse_model.dart';

class QuestionHistoryEntry {
  final String id;
  final String question;
  final int createdAtMilliseconds;
  final List<VerseModel> results;
  final bool isStarred;

  const QuestionHistoryEntry({
    required this.id,
    required this.question,
    required this.createdAtMilliseconds,
    required this.results,
    this.isStarred = false,
  });

  QuestionHistoryEntry copyWith({bool? isStarred}) => QuestionHistoryEntry(
    id: id,
    question: question,
    createdAtMilliseconds: createdAtMilliseconds,
    results: results,
    isStarred: isStarred ?? this.isStarred,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'question': question,
    'createdAtMilliseconds': createdAtMilliseconds,
    'isStarred': isStarred,
    'results': results
        .map(
          (verse) => {
            'bookName': verse.bookName,
            'chapter': verse.chapter,
            'verse': verse.verse,
            'text': verse.text,
          },
        )
        .toList(growable: false),
  };

  static QuestionHistoryEntry? decode(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    final id = value['id'];
    final question = value['question'];
    final createdAtMilliseconds = value['createdAtMilliseconds'];
    final rawResults = value['results'];
    final isStarred = value['isStarred'];
    if (id is! String ||
        question is! String ||
        createdAtMilliseconds is! int ||
        rawResults is! List ||
        isStarred is! bool) {
      return null;
    }

    final results = <VerseModel>[];
    for (final rawVerse in rawResults) {
      if (rawVerse is! Map<String, dynamic>) continue;
      final bookName = rawVerse['bookName'];
      final chapter = rawVerse['chapter'];
      final verse = rawVerse['verse'];
      final text = rawVerse['text'];
      if (bookName is String &&
          chapter is int &&
          verse is int &&
          text is String) {
        results.add(
          VerseModel(
            bookName: bookName,
            chapter: chapter,
            verse: verse,
            text: text,
          ),
        );
      }
    }

    return QuestionHistoryEntry(
      id: id,
      question: question,
      createdAtMilliseconds: createdAtMilliseconds,
      results: List.unmodifiable(results),
      isStarred: isStarred,
    );
  }
}

class QuestionHistoryRepository {
  QuestionHistoryRepository();

  static final instance = QuestionHistoryRepository();
  static const _storageKey = 'question_history.entries';
  static const _maximumEntries = 100;

  final ValueNotifier<List<QuestionHistoryEntry>> current = ValueNotifier(
    const [],
  );

  Future<List<QuestionHistoryEntry>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final rawHistory = preferences.getString(_storageKey);
    if (rawHistory == null) {
      current.value = const [];
      return current.value;
    }

    try {
      final decoded = jsonDecode(rawHistory);
      final entries = decoded is List
          ? decoded
                .map(QuestionHistoryEntry.decode)
                .whereType<QuestionHistoryEntry>()
                .toList()
          : <QuestionHistoryEntry>[];
      current.value = List.unmodifiable(entries);
    } on FormatException {
      await preferences.remove(_storageKey);
      current.value = const [];
    }
    return current.value;
  }

  Future<void> add(String question, List<VerseModel> results) async {
    final entries = await load();
    final now = DateTime.now();
    final newEntry = QuestionHistoryEntry(
      id: now.microsecondsSinceEpoch.toString(),
      question: question,
      createdAtMilliseconds: now.millisecondsSinceEpoch,
      results: List.unmodifiable(results),
    );
    await _save([newEntry, ...entries].take(_maximumEntries).toList());
  }

  Future<void> toggleStar(String id) async {
    final entries = await load();
    await _save([
      for (final entry in entries)
        if (entry.id == id)
          entry.copyWith(isStarred: !entry.isStarred)
        else
          entry,
    ]);
  }

  Future<void> remove(String id) async {
    final entries = await load();
    await _save(entries.where((entry) => entry.id != id).toList());
  }

  Future<void> clear() async => _save(const []);

  Future<void> _save(List<QuestionHistoryEntry> entries) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey,
      jsonEncode(entries.map((entry) => entry.toJson()).toList()),
    );
    current.value = List.unmodifiable(entries);
  }
}
