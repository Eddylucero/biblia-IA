import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:biblia/main.dart';
import 'package:biblia/models/book_model.dart';
import 'package:biblia/models/verse_model.dart';
import 'package:biblia/repositories/bible_repository.dart';
import 'package:biblia/screens/bible/widgets/verse_tile.dart';
import 'package:biblia/repositories/reading_progress_repository.dart';
import 'package:biblia/repositories/favorite_verse_repository.dart';

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
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

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

  testWidgets('testament tabs switch the visible books', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(bibleDataSource: _FakeBibleDataSource()));

    await tester.tap(find.byType(NavigationDestination).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nuevo Testamento'));
    await tester.pumpAndSettle();

    expect(find.text('Mateo'), findsOneWidget);
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
    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();

    expect(find.text('Génesis 2'), findsOneWidget);
    expect(find.text('Versículo real 1:2:1'), findsOneWidget);
    expect(tester.widget<VerseTile>(find.byType(VerseTile)).isSelected, isTrue);
    expect(find.text('Preguntar a IA'), findsNothing);
    expect(find.byIcon(Icons.star_border), findsOneWidget);
    expect(find.byIcon(Icons.border_color), findsOneWidget);
    expect(find.byIcon(Icons.share), findsOneWidget);

    await tester.tap(find.byTooltip('Agregar a favoritos'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Quitar de favoritos'), findsOneWidget);

    final savedFavorites = await FavoriteVerseRepository().load();
    expect(savedFavorites, hasLength(1));
    expect(savedFavorites.single.reference, 'Génesis 2:1');
    expect(savedFavorites.single.text, 'Versículo real 1:2:1');

    await tester.tap(find.byIcon(Icons.arrow_back).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(NavigationDestination).first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Leer capítulo'));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('Génesis 2:1'),
      ),
      findsOneWidget,
    );
    final excerptFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data?.contains('Versículo real 1:2:1') == true,
    );
    expect(excerptFinder, findsOneWidget);
    expect(tester.widget<Text>(excerptFinder).maxLines, 3);

    await tester.ensureVisible(find.text('Colección de favoritos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Colección de favoritos'));
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('Génesis 2:1'),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Versículo real 1:2:1'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back).first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Leer capítulo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Leer capítulo'));
    await tester.pumpAndSettle();

    expect(find.text('Génesis 2'), findsOneWidget);
    expect(tester.widget<VerseTile>(find.byType(VerseTile)).isSelected, isTrue);

    final reloadedProgress = ReadingProgressRepository();
    await reloadedProgress.load();
    expect(reloadedProgress.current.value?.reference, 'Génesis 2:1');
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
