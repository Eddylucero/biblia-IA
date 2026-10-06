import 'dart:async';

import 'package:flutter/material.dart';
import 'package:biblia/repositories/bible_repository.dart';
import 'package:biblia/repositories/reading_progress_repository.dart';
import 'package:biblia/models/book_model.dart';
import 'package:biblia/models/verse_model.dart';

import '../../../../core/constants/app_colors.dart';

class DailyVerseCard extends StatefulWidget {
  final BibleDataSource? dataSource;

  const DailyVerseCard({super.key, this.dataSource});

  @override
  State<DailyVerseCard> createState() => _DailyVerseCardState();
}

class _DailyVerseCardState extends State<DailyVerseCard> {
  final _progressRepository = ReadingProgressRepository.instance;
  late final BibleDataSource _dataSource;
  String? _excerpt;
  String? _requestedExcerptLocation;

  @override
  void initState() {
    super.initState();
    _dataSource = widget.dataSource ?? BibleRepository();
    _progressRepository.current.addListener(_handleProgressChanged);
    unawaited(_progressRepository.load());
  }

  @override
  void dispose() {
    _progressRepository.current.removeListener(_handleProgressChanged);
    super.dispose();
  }

  void _handleProgressChanged() {
    final progress = _progressRepository.current.value;
    final location = progress == null
        ? null
        : '${progress.bookId}:${progress.chapter}:${progress.verseNumber ?? 1}';
    if (location == _requestedExcerptLocation) return;
    _requestedExcerptLocation = location;

    if (progress == null) {
      setState(() => _excerpt = null);
      return;
    }
    unawaited(_loadVerseExcerpt(progress, location!));
  }

  Future<void> _loadVerseExcerpt(
    ReadingProgress progress,
    String location,
  ) async {
    try {
      var bookId = progress.bookId;
      if (bookId <= 0) {
        final books = await _dataSource.getBooks();
        final book = books.cast<BookModel?>().firstWhere(
          (item) =>
              item != null &&
              (item.name == progress.bookName ||
                  item.modernName == progress.bookName),
          orElse: () => null,
        );
        if (book == null) return;
        bookId = book.id;
      }

      final verses = await _dataSource.getChapterVerses(
        bookId: bookId,
        chapter: progress.chapter,
      );
      final targetVerse = progress.verseNumber ?? 1;
      final verse = verses.cast<VerseModel?>().firstWhere(
        (item) => item?.verse == targetVerse,
        orElse: () => null,
      );
      if (!mounted || _requestedExcerptLocation != location) return;
      setState(() => _excerpt = verse?.text);
    } catch (_) {
      if (mounted && _requestedExcerptLocation == location) {
        setState(() => _excerpt = null);
      }
    }
  }

  void _openChapter(BuildContext context, ReadingProgress? progress) {
    final position =
        progress ??
        const ReadingProgress(
          bookId: 0,
          bookName: 'Filipenses',
          chapter: 4,
          chaptersCount: 0,
          verseNumber: 13,
        );
    Navigator.of(context).pushNamed(
      '/chapter',
      arguments: {
        'bookId': position.bookId,
        'bookName': position.bookName,
        'chapterNumber': position.chapter,
        'chaptersCount': position.chaptersCount,
        'selectedVerseNumber': position.verseNumber,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ReadingProgress?>(
      valueListenable: _progressRepository.current,
      builder: (context, progress, _) {
        final reference = progress == null
            ? 'Filipenses 4:13'
            : '${progress.bookName} ${progress.chapter}:${progress.verseNumber ?? 1}';
        final passage = progress == null
            ? '«Todo lo puedo en Cristo que me fortalece.»'
            : _excerpt == null
            ? 'Cargando versículo...'
            : '«$_excerpt»';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'CONTINUAR LEYENDO',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.8,
                  ),
                ),
                const Row(
                  children: [
                    Icon(Icons.menu_book, size: 16, color: AppColors.secondary),
                    SizedBox(width: 4),
                    Text(
                      'Plan Diario',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Container(width: 4, color: AppColors.secondary),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.bookmark_outline,
                                        color: AppColors.secondary,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        progress == null
                                            ? 'Lectura sugerida'
                                            : 'Última lectura',
                                        style: const TextStyle(
                                          color: AppColors.secondary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.bookmark_border,
                                  color: AppColors.onSurfaceVariant,
                                  size: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              passage,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 16,
                                height: 1.4,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: RichText(
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '$reference ',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.onSurface,
                                            fontSize: 14,
                                          ),
                                        ),
                                        TextSpan(
                                          text: progress == null
                                              ? '• RVR1960'
                                              : '• Guardado',
                                          style: const TextStyle(
                                            color: AppColors.outline,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => _openChapter(context, progress),
                                  borderRadius: BorderRadius.circular(8),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 6,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Leer capítulo',
                                          style: TextStyle(
                                            color: AppColors.secondary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward,
                                          color: AppColors.secondary,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
