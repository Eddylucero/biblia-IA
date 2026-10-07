import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/book_model.dart';
import '../../repositories/bible_repository.dart';
import 'widgets/bible_book_tile.dart';
import 'widgets/chapter_selection_sheet.dart';
import 'widgets/voice_bible_search_sheet.dart';

class BibleScreen extends StatefulWidget {
  final BibleDataSource? dataSource;
  final bool autoStartVoiceSearch;

  const BibleScreen({
    super.key,
    this.dataSource,
    this.autoStartVoiceSearch = true,
  });

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  late final BibleDataSource _dataSource;
  late Future<List<BookModel>> _booksFuture;
  int _selectedTestamentTab = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _dataSource = widget.dataSource ?? BibleRepository();
    _booksFuture = _dataSource.getBooks();
  }

  void _openChapterSelector(BookModel book) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChapterSelectionSheet(
        bookId: book.id,
        bookName: book.name,
        testament: book.isNewTestament
            ? 'Nuevo Testamento'
            : 'Antiguo Testamento',
        totalChapters: book.chaptersCount,
        dataSource: _dataSource,
        onSelection: (chapter, verse) {
          Navigator.of(context).pushNamed(
            '/chapter',
            arguments: {
              'bookId': book.id,
              'bookName': book.name,
              'chapterNumber': chapter,
              'chaptersCount': book.chaptersCount,
              'selectedVerseNumber': verse,
            },
          );
        },
      ),
    );
  }

  void _openVoiceBibleSearch(List<BookModel> books) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => VoiceBibleSearchSheet(
        books: books,
        dataSource: _dataSource,
        autoStartListening: widget.autoStartVoiceSearch,
        onReferenceSelected: (reference) {
          Navigator.of(context).pushNamed(
            '/chapter',
            arguments: {
              'bookId': reference.book.id,
              'bookName': reference.book.name,
              'chapterNumber': reference.chapter,
              'chaptersCount': reference.book.chaptersCount,
              'selectedVerseNumber': reference.verse,
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        title: const Text(
          'Biblia',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
      ),
      body: FutureBuilder<List<BookModel>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _buildErrorState();
          }

          final books = snapshot.data ?? const <BookModel>[];
          final testamentBooks = books
              .where(
                (book) => book.isNewTestament == (_selectedTestamentTab == 1),
              )
              .toList(growable: false);
          final query = _searchQuery.trim().toLowerCase();
          final filteredBooks = testamentBooks
              .where((book) {
                return query.isEmpty ||
                    book.name.toLowerCase().contains(query) ||
                    book.modernName.toLowerCase().contains(query);
              })
              .toList(growable: false);
          final oldTestamentCount = books
              .where((book) => !book.isNewTestament)
              .length;
          final newTestamentCount = books
              .where((book) => book.isNewTestament)
              .length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoPill(
                          icon: Icons.menu_book,
                          label: '${books.length} libros',
                        ),
                        _buildVoiceSearchButton(
                          onPressed: () => _openVoiceBibleSearch(books),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Buscar libro',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.secondary,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceContainerLowest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTestamentTab(
                              index: 0,
                              title: 'Antiguo Testamento',
                              bookCount: oldTestamentCount,
                              icon: Icons.menu_book_outlined,
                            ),
                          ),
                          Expanded(
                            child: _buildTestamentTab(
                              index: 1,
                              title: 'Nuevo Testamento',
                              bookCount: newTestamentCount,
                              icon: Icons.auto_stories_outlined,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredBooks.isEmpty
                    ? const Center(child: Text('No se encontraron libros'))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: filteredBooks.length,
                        itemBuilder: (context, index) {
                          final book = filteredBooks[index];
                          final subtitle = book.modernName == book.name
                              ? '${book.chaptersCount} capítulos'
                              : '${book.modernName} · ${book.chaptersCount} capítulos';
                          return BibleBookTile(
                            title: book.name,
                            subtitle: subtitle,
                            chaptersCount: book.chaptersCount,
                            icon: book.isNewTestament
                                ? Icons.auto_stories
                                : Icons.menu_book,
                            onTap: () => _openChapterSelector(book),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTestamentTab({
    required int index,
    required String title,
    required int bookCount,
    required IconData icon,
  }) {
    final isSelected = _selectedTestamentTab == index;
    return Semantics(
      button: true,
      selected: isSelected,
      label: '$title, $bookCount libros',
      child: InkWell(
        onTap: () => setState(() => _selectedTestamentTab = index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? AppColors.secondaryFixed
                    : AppColors.secondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? AppColors.onPrimary
                            : AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$bookCount libros',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.secondaryFixed
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPill({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.secondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceSearchButton({required VoidCallback onPressed}) {
    return Material(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mic_none, size: 16, color: AppColors.secondary),
              SizedBox(width: 6),
              Text(
                'Buscar con voz',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
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
            const Text('No se pudo cargar la Biblia.'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => setState(() {
                _booksFuture = _dataSource.getBooks();
              }),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
