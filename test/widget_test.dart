import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:biblia/main.dart';
import 'package:biblia/models/book_model.dart';
import 'package:biblia/models/verse_model.dart';
import 'package:biblia/repositories/bible_repository.dart';

class _FakeBibleDataSource implements BibleDataSource {
  static const books = [
    BookModel(
      id: 1,
      name: 'Génesis',
      modernName: 'Génesis',
      isNewTestament: false,
      chaptersCount: 2,
    ),
    BookModel(
      id: 40,
      name: 'Mateo',
      modernName: 'Mateo',
      isNewTestament: true,
      chaptersCount: 28,
    ),
  ];

  @override
  Future<List<BookModel>> getBooks() async => books;

  @override
  Future<List<VerseModel>> getChapterVerses({
    required int bookId,
    required int chapter,
  }) async => [
    VerseModel(
      bookName: bookId == 40 ? 'Mateo' : 'Génesis',
      chapter: chapter,
      verse: 1,
      text: 'Versículo real $bookId:$chapter:1',
    ),
  ];
}

void main() {
  testWidgets('opens the home screen', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(bibleDataSource: _FakeBibleDataSource()));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('¿Qué quieres consultar hoy?'), findsOneWidget);
  });

  testWidgets('bottom navigation loads books from the data source', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(bibleDataSource: _FakeBibleDataSource()));

    await tester.tap(find.byType(NavigationDestination).at(1));
    await tester.pumpAndSettle();

    expect(find.text('Génesis'), findsOneWidget);
  });

  testWidgets('selecting a book and chapter opens its verses', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(bibleDataSource: _FakeBibleDataSource()));

    await tester.tap(find.byType(NavigationDestination).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Génesis'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();

    expect(find.text('Génesis 2'), findsOneWidget);
    expect(find.text('Versículo real 1:2:1'), findsOneWidget);
  });

  testWidgets('chapter route loads verses for its book and chapter', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(bibleDataSource: _FakeBibleDataSource()));
    final navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );

    navigator.pushNamed(
      '/chapter',
      arguments: {
        'bookId': 40,
        'bookName': 'Mateo',
        'chapterNumber': 5,
        'chaptersCount': 28,
      },
    );
    await tester.pumpAndSettle();

    expect(find.text('Mateo 5'), findsOneWidget);
    expect(find.text('Versículo real 40:5:1'), findsOneWidget);
  });
}
