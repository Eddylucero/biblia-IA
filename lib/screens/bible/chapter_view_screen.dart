import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/book_model.dart';
import '../../models/verse_model.dart';
import '../../repositories/bible_repository.dart';
import '../../repositories/favorite_verse_repository.dart';
import '../../repositories/reading_progress_repository.dart';
import 'verse_share_screen.dart';
import 'widgets/verse_tile.dart';

class ChapterViewScreen extends StatefulWidget {
  final int bookId;
  final String bookName;
  final int chapterNumber;
  final int chaptersCount;
  final int? selectedVerseNumber;
  final BibleDataSource? dataSource;

  const ChapterViewScreen({
    super.key,
    this.bookId = 0,
    this.bookName = 'Juan',
    this.chapterNumber = 3,
    this.chaptersCount = 0,
    this.selectedVerseNumber,
    this.dataSource,
  });

  @override
  State<ChapterViewScreen> createState() => _ChapterViewScreenState();
}

class _ChapterViewScreenState extends State<ChapterViewScreen> {
  late final BibleDataSource _dataSource;
  final ReadingProgressRepository _readingProgressRepository =
      ReadingProgressRepository.instance;
  final FavoriteVerseRepository _favoriteVerseRepository =
      FavoriteVerseRepository.instance;
  late Future<List<VerseModel>> _versesFuture;
  late int _bookId;
  late int _chapterNumber;
  late int _chaptersCount;
  late int? _selectedVerseNumber;
  final GlobalKey _initialSelectedVerseKey = GlobalKey();
  bool _hasScrolledToInitialVerse = false;
  bool _isBookmarked = false;
  bool _isVerseBookmarked = false;
  double _fontSize = 17;

  @override
  void initState() {
    super.initState();
    _dataSource = widget.dataSource ?? BibleRepository();
    _bookId = widget.bookId;
    _chapterNumber = widget.chapterNumber;
    _chaptersCount = widget.chaptersCount;
    _selectedVerseNumber = widget.selectedVerseNumber;
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

    await _saveReadingProgress();
    final verses = await _dataSource.getChapterVerses(
      bookId: _bookId,
      chapter: _chapterNumber,
    );
    final selectedVerseNumber = _selectedVerseNumber;
    if (selectedVerseNumber != null) {
      final favorites = await _favoriteVerseRepository.load();
      _isVerseBookmarked = favorites.any(
        (favorite) =>
            favorite.bookId == _bookId &&
            favorite.chapter == _chapterNumber &&
            favorite.verse == selectedVerseNumber,
      );
    }
    return verses;
  }

  Future<void> _selectVerse(VerseModel verse) async {
    final selectedVerseNumber = _selectedVerseNumber == verse.verse
        ? null
        : verse.verse;
    setState(() {
      _selectedVerseNumber = selectedVerseNumber;
      _isVerseBookmarked = false;
    });
    await _saveReadingProgress();
    if (selectedVerseNumber == null) return;

    final favorites = await _favoriteVerseRepository.load();
    if (!mounted || _selectedVerseNumber != selectedVerseNumber) return;
    setState(() {
      _isVerseBookmarked = favorites.any(
        (favorite) =>
            favorite.bookId == _bookId &&
            favorite.chapter == _chapterNumber &&
            favorite.verse == selectedVerseNumber,
      );
    });
  }

  Future<void> _toggleFavorite(VerseModel verse) async {
    final isBookmarked = await _favoriteVerseRepository.toggle(
      FavoriteVerse(
        bookId: _bookId,
        bookName: widget.bookName,
        chapter: _chapterNumber,
        verse: verse.verse,
        text: verse.text,
        savedAtMilliseconds: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    if (!mounted || _selectedVerseNumber != verse.verse) return;
    setState(() => _isVerseBookmarked = isBookmarked);
  }

  void _openShareComposer(VerseModel verse) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerseShareScreen(
          reference: '${widget.bookName} $_chapterNumber:${verse.verse}',
          verseText: verse.text,
        ),
      ),
    );
  }

  Future<void> _saveReadingProgress() async {
    try {
      await _readingProgressRepository.save(
        ReadingProgress(
          bookId: _bookId,
          bookName: widget.bookName,
          chapter: _chapterNumber,
          chaptersCount: _chaptersCount,
          verseNumber: _selectedVerseNumber,
        ),
      );
    } catch (error) {
      debugPrint('No se pudo guardar el avance de lectura: $error');
    }
  }

  void _changeChapter(int chapter) {
    if (chapter < 1 || (_chaptersCount > 0 && chapter > _chaptersCount)) {
      return;
    }
    setState(() {
      _chapterNumber = chapter;
      _selectedVerseNumber = null;
      _isVerseBookmarked = false;
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

                final selectedVerseExists = verses.any(
                  (verse) => verse.verse == widget.selectedVerseNumber,
                );
                if (!_hasScrolledToInitialVerse && selectedVerseExists) {
                  _hasScrolledToInitialVerse = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final selectedContext =
                        _initialSelectedVerseKey.currentContext;
                    if (mounted && selectedContext != null) {
                      Scrollable.ensureVisible(
                        selectedContext,
                        alignment: 0.25,
                        duration: const Duration(milliseconds: 520),
                        curve: Curves.easeOutCubic,
                      );
                    }
                  });
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  child: Column(
                    children: [
                      Padding(
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
                      ),
                      ...verses.map(
                        (verse) => VerseTile(
                          key: verse.verse == widget.selectedVerseNumber
                              ? _initialSelectedVerseKey
                              : ValueKey<int>(verse.verse),
                          number: verse.verse,
                          text: verse.text,
                          fontSize: _fontSize,
                          isSelected: _selectedVerseNumber == verse.verse,
                          isBookmarked: _isVerseBookmarked,
                          onTap: () => _selectVerse(verse),
                          onBookmark: () => _toggleFavorite(verse),
                          onShare: () => _openShareComposer(verse),
                        ),
                      ),
                    ],
                  ),
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
