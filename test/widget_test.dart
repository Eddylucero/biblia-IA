import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:biblia/main.dart';
import 'package:biblia/models/book_model.dart';
import 'package:biblia/models/verse_model.dart';
import 'package:biblia/repositories/bible_repository.dart';
import 'package:biblia/screens/bible/widgets/verse_tile.dart';
import 'package:biblia/screens/bible/widgets/voice_bible_search_sheet.dart';
import 'package:biblia/repositories/reading_progress_repository.dart';
import 'package:biblia/repositories/favorite_verse_repository.dart';
import 'package:biblia/repositories/question_history_repository.dart';
import 'package:biblia/screens/history/widgets/history_card.dart';
import 'package:biblia/screens/bible/voice_search_screen.dart';
import 'package:biblia/screens/bible/bible_screen.dart';

class _FakeBibleDataSource implements BibleDataSource {
  final Completer<List<VerseModel>>? pendingSearch;

  _FakeBibleDataSource({this.pendingSearch});

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

  @override
  Future<List<VerseModel>> searchVerses(String query) async {
    if (pendingSearch != null) return pendingSearch!.future;
    final normalized = query.toLowerCase();
    if (normalized.contains('jesus') || normalized.contains('lloro')) {
      return const [
        VerseModel(
          bookName: 'Juan',
          chapter: 11,
          verse: 35,
          text: 'Jesús lloró.',
        ),
      ];
    }
    if (normalized.contains('noe') ||
        normalized.contains('noé') ||
        normalized.contains('barca')) {
      return const [
        VerseModel(
          bookName: 'Génesis',
          chapter: 6,
          verse: 14,
          text: 'Hazte un arca de madera de gofer.',
        ),
      ];
    }
    return const [];
  }
}

Future<void> _submitQuestion(WidgetTester tester, String question) async {
  await tester.enterText(find.byType(TextField).first, question);
  await tester.testTextInput.receiveAction(TextInputAction.search);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('opens the home screen', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(bibleDataSource: _FakeBibleDataSource()));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('¿Qué quieres consultar hoy?'), findsOneWidget);
    expect(find.byTooltip('Buscar en la Biblia'), findsOneWidget);
  });

  test('voice search uses no more than five recognized words', () {
    expect(
      limitVoiceSearchWords('busca donde Jesús lloró por Lázaro en Betania'),
      'busca donde Jesús lloró por',
    );
    expect(limitVoiceSearchWords('Jesús lloró'), 'Jesús lloró');
  });

  test('voice reference parser resolves Spanish book chapter and verse', () {
    final reference = parseVoiceBibleReference(
      'Juan capítulo once versículo treinta y cinco',
      [
        const BookModel(
          id: 43,
          name: 'Juan',
          modernName: 'Juan',
          isNewTestament: true,
          chaptersCount: 21,
        ),
      ],
    );

    expect(reference?.book.id, 43);
    expect(reference?.chapter, 11);
    expect(reference?.verse, 35);
  });

  test('voice reference parser accepts words before the book name', () {
    final reference = parseVoiceBibleReference(
      'Busca en el libro de Juan capítulo once versículo treinta y cinco',
      [
        const BookModel(
          id: 43,
          name: 'Juan',
          modernName: 'Juan',
          isNewTestament: true,
          chaptersCount: 21,
        ),
      ],
    );

    expect(reference?.book.name, 'Juan');
    expect(reference?.chapter, 11);
    expect(reference?.verse, 35);
  });

  test('voice reference parser rejects incomplete or invalid references', () {
    const books = [
      BookModel(
        id: 43,
        name: 'Juan',
        modernName: 'Juan',
        isNewTestament: true,
        chaptersCount: 21,
      ),
    ];

    expect(parseVoiceBibleReference('Juan capítulo tres', books), isNull);
    expect(
      parseVoiceBibleReference('Juan capítulo noventa versículo dos', books),
      isNull,
    );
  });

  testWidgets('Bible voice button opens its listening modal', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BibleScreen(
          dataSource: _FakeBibleDataSource(),
          autoStartVoiceSearch: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Buscar con voz'));
    await tester.pumpAndSettle();

    expect(find.byType(VoiceBibleSearchSheet), findsOneWidget);
    expect(find.text('Buscar una referencia'), findsOneWidget);
    expect(find.textContaining('transcripción aparecerá aquí'), findsOneWidget);
  });

  testWidgets('voice search opens from Home resources', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        bibleDataSource: _FakeBibleDataSource(),
        autoStartVoiceSearch: false,
      ),
    );

    await tester.ensureVisible(find.text('Buscar en la Biblia'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buscar en la Biblia'));
    await tester.pumpAndSettle();

    expect(find.byType(VoiceSearchScreen), findsOneWidget);
    expect(
      find.text('La transcripción aparecerá aquí mientras hablas.'),
      findsOneWidget,
    );
    expect(find.byTooltip('Empezar a hablar'), findsOneWidget);
  });

  testWidgets('Bible question finds and opens a matching verse', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(bibleDataSource: _FakeBibleDataSource()));

    await _submitQuestion(tester, 'Jesus lloro');
    await tester.pumpAndSettle();

    expect(find.text('Juan 11:35'), findsOneWidget);
    expect(find.text('Jesús lloró.'), findsOneWidget);

    await tester.tap(find.text('Jesús lloró.'));
    await tester.pumpAndSettle();
    expect(find.text('Juan 11'), findsOneWidget);
  });

  testWidgets('Bible question finds ark passages from Noah and boat keywords', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(bibleDataSource: _FakeBibleDataSource()));

    await _submitQuestion(tester, 'Noe y la barca');
    await tester.pumpAndSettle();

    expect(find.text('Génesis 6:14'), findsOneWidget);
    expect(find.text('Hazte un arca de madera de gofer.'), findsOneWidget);
  });

  testWidgets(
    'Bible question asks for clearer words when there are no matches',
    (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(bibleDataSource: _FakeBibleDataSource()));

      await _submitQuestion(tester, 'palabra inexistente');
      await tester.pumpAndSettle();

      expect(find.textContaining('Especifica otras palabras'), findsOneWidget);
    },
  );

  testWidgets('editing the typed question clears stale results', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(bibleDataSource: _FakeBibleDataSource()));

    await _submitQuestion(tester, 'Jesus lloro');
    await tester.pumpAndSettle();
    expect(find.text('Juan 11:35'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Noe');
    await tester.pumpAndSettle();

    expect(find.text('Juan 11:35'), findsNothing);
    expect(find.text('Jesús lloró.'), findsNothing);
  });

  testWidgets(
    'Bible search shows a blurred spinner while the query is pending',
    (WidgetTester tester) async {
      final pendingSearch = Completer<List<VerseModel>>();
      await tester.pumpWidget(
        MyApp(
          bibleDataSource: _FakeBibleDataSource(pendingSearch: pendingSearch),
        ),
      );

      await _submitQuestion(tester, 'Jesus lloro');
      await tester.pump();

      expect(find.text('Buscando en la Biblia...'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);

      pendingSearch.complete(const [
        VerseModel(
          bookName: 'Juan',
          chapter: 11,
          verse: 35,
          text: 'Jesús lloró.',
        ),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('Buscando en la Biblia...'), findsNothing);
      expect(find.text('Juan 11:35'), findsOneWidget);
    },
  );

  testWidgets(
    'Home history opens stored searches and supports star and delete',
    (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(bibleDataSource: _FakeBibleDataSource()));

      await _submitQuestion(tester, 'Noe y la barca');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Historial de Preguntas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Historial de Preguntas'));
      await tester.pumpAndSettle();

      expect(find.text('Noe y la barca'), findsOneWidget);
      final historyCard = find.byType(HistoryCard);
      expect(historyCard, findsOneWidget);
      await tester.tap(
        find.descendant(
          of: historyCard,
          matching: find.byIcon(Icons.star_border),
        ),
      );
      await tester.pumpAndSettle();

      final savedHistory = await QuestionHistoryRepository().load();
      expect(savedHistory, hasLength(1));
      expect(savedHistory.single.isStarred, isTrue);
      expect(savedHistory.single.results.single.bookName, 'Génesis');
      expect(savedHistory.single.results.single.chapter, 6);
      expect(savedHistory.single.results.single.verse, 14);

      await tester.tap(find.text('Ver resultados'));
      await tester.pumpAndSettle();
      expect(find.text('Hazte un arca de madera de gofer.'), findsOneWidget);
      await tester.tap(find.text('Cerrar'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: historyCard,
          matching: find.byIcon(Icons.delete_outline),
        ),
      );
      await tester.pumpAndSettle();
      expect(await QuestionHistoryRepository().load(), isEmpty);

      await QuestionHistoryRepository.instance.add('Jesus lloro', const [
        VerseModel(
          bookName: 'Juan',
          chapter: 11,
          verse: 35,
          text: 'Jesús lloró.',
        ),
      ]);
      await tester.pumpAndSettle();
      expect(find.text('Jesus lloro'), findsOneWidget);

      await tester.tap(find.text('Vaciar todo el historial'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Vaciar'));
      await tester.pumpAndSettle();
      expect(await QuestionHistoryRepository().load(), isEmpty);
    },
  );

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
