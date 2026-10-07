import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../repositories/favorite_verse_repository.dart';
import 'widgets/favorite_verse_card.dart';
import 'widgets/favorites_audio_card.dart';

class FavoriteVerseItem {
  final String id;
  final String tag;
  final String date;
  final String scriptureText;
  final String reference;
  final Color accentColor;
  final String? note;
  final bool hasAiDeepDive;

  FavoriteVerseItem({
    required this.id,
    required this.tag,
    required this.date,
    required this.scriptureText,
    required this.reference,
    required this.accentColor,
    this.note,
    this.hasAiDeepDive = false,
  });

  factory FavoriteVerseItem.fromFavorite(FavoriteVerse favorite) {
    return FavoriteVerseItem(
      id: favorite.id,
      tag: 'favorito',
      date: favorite.dateLabel,
      scriptureText: favorite.text,
      reference: favorite.reference,
      accentColor: AppColors.secondary,
    );
  }
}

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoriteVerseRepository _repository = FavoriteVerseRepository.instance;
  final TextEditingController _searchController = TextEditingController();
  List<FavoriteVerseItem> _verses = [];

  @override
  void initState() {
    super.initState();
    _repository.current.addListener(_handleFavoritesChanged);
    unawaited(_repository.load());
  }

  @override
  void dispose() {
    _repository.current.removeListener(_handleFavoritesChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _handleFavoritesChanged() {
    if (!mounted) return;
    setState(() {
      _verses = _repository.current.value
          .map(FavoriteVerseItem.fromFavorite)
          .toList(growable: false);
    });
  }

  List<FavoriteVerseItem> get _filteredVerses {
    final query = _searchController.text.toLowerCase().trim();
    return _verses.where((verse) {
      final matchesSearch =
          query.isEmpty ||
          verse.scriptureText.toLowerCase().contains(query) ||
          verse.reference.toLowerCase().contains(query) ||
          (verse.note != null && verse.note!.toLowerCase().contains(query));
      return matchesSearch;
    }).toList();
  }

  void _removeVerse(String id) {
    unawaited(_repository.remove(id));
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredVerses;

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
              'Lectura Bíblica',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.bookmark_border,
              color: AppColors.onSurfaceVariant,
            ),
            onPressed: () {},
          ),
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
            // Sub-header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COLECCIÓN PERSONAL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      'Mis favoritos',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryFixed,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_stories,
                        size: 14,
                        color: AppColors.onSecondaryFixed,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_verses.length} versículos',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSecondaryFixed,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Card Editorial "Sugerencia de hoy"
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 14,
                              color: AppColors.secondary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Sugerencia de hoy',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: const TextSpan(
                            text: 'Revisitar pasajes de ',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
                            ),
                            children: [
                              TextSpan(
                                text: 'Paz',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              TextSpan(
                                text:
                                    ' fomenta serenidad en tu jornada matutina.',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 60,
                      height: 60,
                      color: AppColors.secondaryFixed.withValues(alpha: 0.45),
                      child: const Icon(
                        Icons.wb_sunny_outlined,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Campo de Búsqueda
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  icon: const Icon(
                    Icons.search,
                    color: AppColors.outline,
                    size: 20,
                  ),
                  hintText: 'Buscar versículos o libros...',
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
                            color: AppColors.outline,
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

            const SizedBox(height: 16),

            const SizedBox(height: 20),

            // Stream / Lista de Versículos
            if (filteredList.isEmpty)
              _buildEmptyState()
            else
              ...filteredList.map((verse) {
                Widget? bottomAction;

                if (verse.hasAiDeepDive) {
                  bottomAction = Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.secondaryFixed,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.psychology,
                          size: 18,
                          color: AppColors.onSecondaryFixed,
                        ),
                      ),
                      title: const Text(
                        'Preguntar a IA sobre este versículo',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      subtitle: const Text(
                        'Contexto histórico, exégesis y aplicación',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: AppColors.outline,
                      ),
                      onTap: () {},
                    ),
                  );
                } else if (verse.note != null) {
                  bottomAction = Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.label_outline,
                            size: 16,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            verse.note!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.chevron_right, size: 16),
                        label: const Text('Estudiar pasaje'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return FavoriteVerseCard(
                  key: ValueKey(verse.id),
                  tag: verse.tag,
                  date: verse.date,
                  scriptureText: verse.scriptureText,
                  reference: verse.reference,
                  accentColor: verse.accentColor,
                  bottomAction: bottomAction,
                  onDismiss: () => _removeVerse(verse.id),
                );
              }),

            const SizedBox(height: 12),

            // Tarjeta de Audio Devocional en el fondo
            FavoritesAudioCard(totalVerses: _verses.length, onPlay: () {}),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.secondaryFixed.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.menu_book,
              size: 28,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Aún no tienes favoritos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Explora la Biblia y pulsa la estrella de un versículo para guardarlo aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed('/bible'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Explorar Biblia'),
          ),
        ],
      ),
    );
  }
}
