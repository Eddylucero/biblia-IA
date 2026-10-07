import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'package:biblia/models/verse_model.dart';
import 'package:biblia/repositories/bible_repository.dart';
import 'package:biblia/repositories/question_history_repository.dart';
import '../../../../core/constants/app_colors.dart';

class AiPromptCard extends StatefulWidget {
  final BibleDataSource? dataSource;

  const AiPromptCard({super.key, this.dataSource});

  @override
  State<AiPromptCard> createState() => _AiPromptCardState();
}

class _AiPromptCardState extends State<AiPromptCard> {
  final _questionController = TextEditingController();
  final _historyRepository = QuestionHistoryRepository.instance;
  late final BibleDataSource _dataSource;
  List<VerseModel> _results = const [];
  bool _isSearching = false;
  bool _hasSearched = false;
  String? _feedback;

  @override
  void initState() {
    super.initState();
    _dataSource = widget.dataSource ?? BibleRepository();
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final question = _questionController.text.trim();
    if (question.isEmpty || _isSearching) return;

    setState(() {
      _isSearching = true;
      _hasSearched = true;
      _feedback = null;
      _results = const [];
    });

    final overlayFuture = showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.12),
      builder: (context) => PopScope(
        canPop: false,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox.square(
                    dimension: 34,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.secondary,
                    ),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Buscando en la Biblia...',
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    unawaited(overlayFuture);

    try {
      final results = await _dataSource.searchVerses(question);
      try {
        await _historyRepository.add(question, results);
      } catch (_) {
        // Keep the search result usable if local history storage fails.
      }
      if (!mounted) return;
      setState(() {
        _results = results;
        _feedback = results.isEmpty
            ? 'No encontré coincidencias. Especifica otras palabras, como un nombre o una frase bíblica.'
            : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _feedback = 'No pude consultar la Biblia. Inténtalo de nuevo.';
      });
    } finally {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        setState(() => _isSearching = false);
      }
    }
  }

  void _openVerse(VerseModel verse) {
    Navigator.of(context).pushNamed(
      '/chapter',
      arguments: {
        'bookName': verse.bookName,
        'chapterNumber': verse.chapter,
        'selectedVerseNumber': verse.verse,
      },
    );
  }

  void _handleQuestionChanged(String value) {
    if (!_hasSearched && _results.isEmpty && _feedback == null) return;
    setState(() {
      _hasSearched = false;
      _results = const [];
      _feedback = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Text(
            'Pregunta a Biblia',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Encuentra orientación profunda y respuestas fundamentadas en las Sagradas Escrituras.',
            style: TextStyle(
              color: Color(0xFFBBC7DD),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 52,
            padding: const EdgeInsets.only(left: 12, right: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.psychology_alt,
                  color: AppColors.secondary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    textInputAction: TextInputAction.search,
                    onChanged: _handleQuestionChanged,
                    onSubmitted: (_) => _search(),
                    decoration: InputDecoration(
                      hintText: 'Escribe tu pregunta o duda...',
                      hintStyle: TextStyle(
                        color: AppColors.outline,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Buscar en la Biblia',
                  onPressed: _isSearching ? null : _search,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: _isSearching
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.secondaryFixed,
                          ),
                        )
                      : const Icon(
                          Icons.arrow_forward,
                          color: AppColors.secondaryFixed,
                          size: 20,
                        ),
                ),
              ],
            ),
          ),
          if (_hasSearched) ...[
            const SizedBox(height: 12),
            if (_feedback != null)
              Text(
                _feedback!,
                style: const TextStyle(
                  color: AppColors.secondaryFixed,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            for (final verse in _results)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () => _openVerse(verse),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${verse.bookName} ${verse.chapter}:${verse.verse}',
                            style: const TextStyle(
                              color: AppColors.secondaryFixed,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            verse.text,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text(
                  'Temas:',
                  style: TextStyle(color: Color(0xFFBBC7DD), fontSize: 12),
                ),
                const SizedBox(width: 8),
                _buildTopicChip('Paz interior'),
                _buildTopicChip('Perdón'),
                _buildTopicChip('Esperanza'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
