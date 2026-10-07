import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../repositories/question_history_repository.dart';
import '../../models/verse_model.dart';
import 'widgets/history_card.dart';

class HistoryItem {
  final String id;
  final String timeframe; // 'semana' | 'mes'
  final String dateText;
  final String title;
  final String previewText;
  final int versesCount;
  final String keywords;
  bool isStarred;

  HistoryItem({
    required this.id,
    required this.timeframe,
    required this.dateText,
    required this.title,
    required this.previewText,
    required this.versesCount,
    required this.keywords,
    this.isStarred = false,
  });
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final QuestionHistoryRepository _repository =
      QuestionHistoryRepository.instance;
  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = 'all'; // 'all', 'saved', 'results'
  List<HistoryItem> _items = [];

  @override
  void initState() {
    super.initState();
    _repository.current.addListener(_handleHistoryChanged);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    await _repository.load();
    if (mounted) _handleHistoryChanged();
  }

  void _handleHistoryChanged() {
    if (!mounted) return;
    final now = DateTime.now();
    setState(() {
      _items = _repository.current.value
          .map((entry) {
            final date = DateTime.fromMillisecondsSinceEpoch(
              entry.createdAtMilliseconds,
            ).toLocal();
            final age = now.difference(date);
            final timeframe = age.inDays < 7 ? 'semana' : 'mes';
            final time =
                '${date.hour.toString().padLeft(2, '0')}:'
                '${date.minute.toString().padLeft(2, '0')}';
            final dateText = age.inDays == 0
                ? 'Hoy, $time'
                : age.inDays == 1
                ? 'Ayer, $time'
                : '${date.day.toString().padLeft(2, '0')}/'
                      '${date.month.toString().padLeft(2, '0')} • $time';
            final previewText = entry.results.isEmpty
                ? 'No se encontraron coincidencias para esta consulta.'
                : entry.results
                      .map(
                        (verse) =>
                            '${verse.bookName} ${verse.chapter}:${verse.verse} — ${verse.text}',
                      )
                      .join(' ');
            return HistoryItem(
              id: entry.id,
              timeframe: timeframe,
              dateText: dateText,
              title: entry.question,
              previewText: previewText,
              versesCount: entry.results.length,
              keywords: entry.question.toLowerCase(),
              isStarred: entry.isStarred,
            );
          })
          .toList(growable: false);
    });
  }

  @override
  void dispose() {
    _repository.current.removeListener(_handleHistoryChanged);
    _searchController.dispose();
    super.dispose();
  }

  List<HistoryItem> get _filteredItems {
    final query = _searchController.text.toLowerCase().trim();

    return _items.where((item) {
      // Filtro por Chips
      if (_activeFilter == 'saved' && !item.isStarred) return false;
      if (_activeFilter == 'results' && item.versesCount == 0) return false;

      // Filtro por Buscador
      if (query.isEmpty) return true;
      final fullContent = '${item.title} ${item.previewText} ${item.keywords}'
          .toLowerCase();
      return fullContent.contains(query);
    }).toList();
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vaciar historial'),
        content: const Text(
          '¿Deseas borrar todas tus preguntas guardadas? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _repository.clear().then((_) {
                if (context.mounted) Navigator.of(context).pop();
              });
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;
    final semanaItems = filtered.where((e) => e.timeframe == 'semana').toList();
    final mesItems = filtered.where((e) => e.timeframe == 'mes').toList();

    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_stories,
                size: 18,
                color: AppColors.secondaryFixed,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Biblia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surfaceContainerLow,
              child: Icon(
                Icons.person,
                size: 18,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sub-header Context
            const Row(
              children: [
                Icon(Icons.auto_stories, size: 18, color: AppColors.secondary),
                SizedBox(width: 6),
                Text(
                  'CONSULTAS LOCALES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              'Historial de Consultas',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const Text(
              'Tus preguntas y los pasajes encontrados en la Biblia.',
              style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
            ),

            const SizedBox(height: 16),

            // Barra de Búsqueda
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  icon: const Icon(
                    Icons.search,
                    color: AppColors.secondary,
                    size: 22,
                  ),
                  hintText: 'Buscar preguntas o pasajes...',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: AppColors.outline,
                  ),
                  border: InputBorder.none,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 18,
                            color: AppColors.onSurfaceVariant,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Quick Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    'all',
                    'Todas (${_items.length})',
                    Icons.all_inclusive,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip('saved', 'Guardadas', Icons.bookmark),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'results',
                    'Con resultados',
                    Icons.menu_book,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Contenido Principal
            if (filtered.isEmpty)
              _buildEmptyState()
            else ...[
              // Sección: Esta Semana
              if (semanaItems.isNotEmpty) ...[
                _buildSectionHeader(
                  'Esta semana',
                  '${semanaItems.length} consultas',
                  AppColors.secondary,
                ),
                const SizedBox(height: 8),
                ...semanaItems.map((item) => _buildCard(item)),
              ],

              // Sección: El Mes Pasado
              if (mesItems.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildSectionHeader(
                  'El mes pasado',
                  '${mesItems.length} consulta',
                  AppColors.outlineVariant,
                ),
                const SizedBox(height: 8),
                ...mesItems.map((item) => _buildCard(item)),
              ],
            ],

            const SizedBox(height: 24),

            // Footer Trigger: Vaciar historial
            Center(
              child: Column(
                children: [
                  TextButton.icon(
                    onPressed: _clearHistory,
                    icon: const Icon(Icons.delete_sweep, size: 18),
                    label: const Text('Vaciar todo el historial'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.outline,
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Tus consultas se guardan en este dispositivo',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.outlineVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, IconData icon) {
    final isSelected = _activeFilter == key;
    return ChoiceChip(
      showCheckmark: false,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? AppColors.onPrimary : AppColors.secondary,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _activeFilter = key);
      },
      selectedColor: AppColors.primaryContainer,
      backgroundColor: AppColors.surfaceContainerLow,
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
    );
  }

  Widget _buildSectionHeader(String title, String countText, Color dotColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: dotColor == AppColors.secondary
                    ? AppColors.secondary
                    : AppColors.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        Text(
          countText,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(HistoryItem item) {
    return HistoryCard(
      key: ValueKey(item.id),
      dateText: item.dateText,
      title: item.title,
      previewText: item.previewText,
      versesCount: item.versesCount,
      isStarred: item.isStarred,
      accentColor: item.isStarred
          ? AppColors.secondary
          : AppColors.secondaryFixedDim,
      categoryIcon: item.isStarred
          ? Icons.psychology_alt
          : Icons.chat_bubble_outline,
      onOpen: () => _openHistoryItem(item),
      onToggleStar: () => _repository.toggleStar(item.id),
      onDelete: () => _repository.remove(item.id),
    );
  }

  void _openHistoryItem(HistoryItem item) {
    final entry = _repository.current.value
        .where((candidate) => candidate.id == item.id)
        .firstOrNull;
    if (entry == null) return;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(item.title),
        content: entry.results.isEmpty
            ? const Text('No se encontraron versículos para esta consulta.')
            : ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: entry.results
                        .map((verse) => _buildVerseResult(verse))
                        .toList(growable: false),
                  ),
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildVerseResult(VerseModel verse) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${verse.bookName} ${verse.chapter}:${verse.verse}',
            style: const TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(verse.text),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.secondaryFixed.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off,
              size: 28,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No hay consultas para mostrar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Haz una pregunta en Inicio para buscar pasajes y guardarlos en este historial.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
