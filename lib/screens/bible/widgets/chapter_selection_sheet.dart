import 'package:flutter/material.dart';
import 'package:biblia/core/constants/app_colors.dart';
import 'package:biblia/models/verse_model.dart';
import 'package:biblia/repositories/bible_repository.dart';

class ChapterSelectionSheet extends StatefulWidget {
  final int bookId;
  final String bookName;
  final String testament;
  final int totalChapters;
  final BibleDataSource dataSource;
  final void Function(int chapter, int? verse) onSelection;

  const ChapterSelectionSheet({
    super.key,
    required this.bookId,
    required this.bookName,
    required this.testament,
    required this.totalChapters,
    required this.dataSource,
    required this.onSelection,
  });

  @override
  State<ChapterSelectionSheet> createState() => _ChapterSelectionSheetState();
}

class _ChapterSelectionSheetState extends State<ChapterSelectionSheet> {
  int? _selectedChapter;
  Future<List<VerseModel>>? _versesFuture;

  void _selectChapter(int chapter) {
    setState(() {
      _selectedChapter = chapter;
      _versesFuture = widget.dataSource.getChapterVerses(
        bookId: widget.bookId,
        chapter: chapter,
      );
    });
  }

  void _openSelection(int? verse) {
    final chapter = _selectedChapter;
    if (chapter == null) return;
    Navigator.of(context).pop();
    widget.onSelection(chapter, verse);
  }

  @override
  Widget build(BuildContext context) {
    final selectedChapter = _selectedChapter;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                if (selectedChapter != null)
                  IconButton(
                    tooltip: 'Volver a capítulos',
                    icon: const Icon(Icons.arrow_back),
                    color: AppColors.onSurfaceVariant,
                    onPressed: () => setState(() {
                      _selectedChapter = null;
                      _versesFuture = null;
                    }),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.testament.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                      Text(
                        selectedChapter == null
                            ? widget.bookName
                            : '${widget.bookName} · Capítulo $selectedChapter',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Cerrar',
                  icon: const Icon(Icons.close),
                  color: AppColors.onSurfaceVariant,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              selectedChapter == null
                  ? 'Selecciona un capítulo para comenzar la lectura.'
                  : 'Selecciona un versículo o abre el capítulo completo.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.48,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: selectedChapter == null
                    ? _buildChapterGrid()
                    : _buildVerseGrid(selectedChapter),
              ),
            ),
            if (selectedChapter != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _openSelection(null),
                  icon: const Icon(Icons.menu_book_outlined),
                  label: const Text('Leer capítulo completo'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChapterGrid() {
    return GridView.builder(
      key: const ValueKey('chapter-grid'),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: widget.totalChapters,
      itemBuilder: (context, index) {
        final chapter = index + 1;
        return _buildNumberTile(
          value: chapter,
          isSelected: false,
          onTap: () => _selectChapter(chapter),
        );
      },
    );
  }

  Widget _buildVerseGrid(int chapter) {
    return FutureBuilder<List<VerseModel>>(
      key: ValueKey('verses-$chapter'),
      future: _versesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('No se pudieron cargar los versículos.'),
                TextButton.icon(
                  onPressed: () => setState(() {
                    _versesFuture = widget.dataSource.getChapterVerses(
                      bookId: widget.bookId,
                      chapter: chapter,
                    );
                  }),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final verses = snapshot.data ?? const <VerseModel>[];
        if (verses.isEmpty) {
          return const Center(
            child: Text('Este capítulo no contiene versículos.'),
          );
        }
        return GridView.builder(
          key: const ValueKey('verse-grid'),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: verses.length,
          itemBuilder: (context, index) {
            final verse = verses[index];
            return _buildNumberTile(
              value: verse.verse,
              isSelected: false,
              onTap: () => _openSelection(verse.verse),
            );
          },
        );
      },
    );
  }

  Widget _buildNumberTile({
    required int value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected
          ? AppColors.secondaryFixed
          : AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Text(
            '$value',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
