import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/book_model.dart';
import '../../models/verse_model.dart';
import '../../repositories/bible_repository.dart';
import 'widgets/verse_tile.dart';

class ChapterViewScreen extends StatefulWidget {
  final int bookId;
  final String bookName;
  final int chapterNumber;
  final int chaptersCount;
  final BibleDataSource? dataSource;

  const ChapterViewScreen({
    super.key,
    this.bookId = 0,
    this.bookName = 'Juan',
    this.chapterNumber = 3,
    this.chaptersCount = 0,
    this.dataSource,
  });

  @override
  State<ChapterViewScreen> createState() => _ChapterViewScreenState();
}

class _ChapterViewScreenState extends State<ChapterViewScreen> {
  late final BibleDataSource _dataSource;
  late Future<List<VerseModel>> _versesFuture;
  late int _bookId;
  late int _chapterNumber;
  late int _chaptersCount;
  int? _selectedVerseNumber;
  bool _isBookmarked = false;
  double _fontSize = 17;

  @override
  void initState() {
    super.initState();
    _dataSource = widget.dataSource ?? BibleRepository();
    _bookId = widget.bookId;
    _chapterNumber = widget.chapterNumber;
    _chaptersCount = widget.chaptersCount;
    _versesFuture = _loadVerses();
  }

  Future<List<VerseModel>> _loadVerses() async {
    if (_bookId <= 0) {
      final books = await _dataSource.getBooks();
      final book = books.cast<BookModel?>().firstWhere(
        (item) =>
            item != null &&
            (item.name == widget.bookName ||
                item.modernName == widget.bookName),
        orElse: () => null,
      );
      if (book == null) {
        throw StateError('No se encontró el libro ${widget.bookName}.');
      }
      _bookId = book.id;
      _chaptersCount = book.chaptersCount;
    }

    return _dataSource.getChapterVerses(
      bookId: _bookId,
      chapter: _chapterNumber,
    );
  }

  void _changeChapter(int chapter) {
    if (chapter < 1 || (_chaptersCount > 0 && chapter > _chaptersCount)) {
      return;
    }
    setState(() {
      _chapterNumber = chapter;
      _selectedVerseNumber = null;
      _versesFuture = _loadVerses();
    });
  }

  void _cycleFontSize() {
    setState(() {
      _fontSize = _fontSize >= 21 ? 17 : _fontSize + 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.bookName} $_chapterNumber',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Cambiar tamaño del texto',
            icon: const Text(
              'Aa',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: _cycleFontSize,
          ),
          IconButton(
            tooltip: _isBookmarked ? 'Quitar marcador' : 'Guardar marcador',
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: AppColors.secondary,
            ),
            onPressed: () => setState(() => _isBookmarked = !_isBookmarked),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _chapterNumber > 1
                      ? () => _changeChapter(_chapterNumber - 1)
                      : null,
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('Anterior'),
                ),
                const Text(
                  'REINA VALERA 1960',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                TextButton(
                  onPressed:
                      _chaptersCount == 0 || _chapterNumber < _chaptersCount
                      ? () => _changeChapter(_chapterNumber + 1)
                      : null,
                  child: const Row(
                    children: [Text('Siguiente'), Icon(Icons.chevron_right)],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<VerseModel>>(
              future: _versesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _buildErrorState();
                }

                final verses = snapshot.data ?? const <VerseModel>[];
                if (verses.isEmpty) {
                  return const Center(
                    child: Text('Este capítulo no contiene versículos.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  itemCount: verses.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          children: [
                            Text(
                              widget.bookName.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Capítulo $_chapterNumber',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final verse = verses[index - 1];
                    return VerseTile(
                      number: verse.verse,
                      text: verse.text,
                      fontSize: _fontSize,
                      isSelected: _selectedVerseNumber == verse.verse,
                      onTap: () => setState(() {
                        _selectedVerseNumber =
                            _selectedVerseNumber == verse.verse
                            ? null
                            : verse.verse;
                      }),
                      onAskAI: () => Navigator.of(context).pushNamed(
                        '/chat',
                        arguments: {
                          'bookName': widget.bookName,
                          'chapterNumber': _chapterNumber,
                          'verseNumber': verse.verse,
                          'verseText': verse.text,
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No se pudo cargar este capítulo.'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => setState(() => _versesFuture = _loadVerses()),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
