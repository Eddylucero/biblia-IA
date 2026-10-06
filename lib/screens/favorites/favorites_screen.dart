import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
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
}

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTag = 'all';

  final List<String> _tags = ['all', 'paz', 'fe', 'esperanza', 'fortaleza'];

  final List<FavoriteVerseItem> _verses = [
    FavoriteVerseItem(
      id: 'juan316',
      tag: 'esperanza',
      date: '12 de Octubre, 2024',
      scriptureText:
          'Porque de tal manera amó Dios al mundo, que ha dado a su Hijo unigénito, para que todo aquel que en él cree, no se pierda, mas tenga vida eterna.',
      reference: 'Juan 3:16',
      accentColor: AppColors.secondary,
      hasAiDeepDive: true,
    ),
    FavoriteVerseItem(
      id: 'isaias4110',
      tag: 'fortaleza',
      date: '05 de Octubre, 2024',
      scriptureText:
          'No temas, porque yo estoy contigo; no desmayes, porque yo soy tu Dios que te esfuerzo; siempre te ayudaré, siempre te sustentaré con la diestra de mi justicia.',
      reference: 'Isaías 41:10',
      accentColor: AppColors.secondaryFixedDim,
      note: 'Ánimo personal',
    ),
    FavoriteVerseItem(
      id: 'salmo231',
      tag: 'paz',
      date: '28 de Septiembre, 2024',
      scriptureText: 'El Señor es mi pastor; nada me faltará.',
      reference: 'Salmos 23:1',
      accentColor: AppColors.secondaryFixed,
      note: 'Oración nocturna',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FavoriteVerseItem> get _filteredVerses {
    final query = _searchController.text.toLowerCase().trim();
    return _verses.where((verse) {
      final matchesTag =
          _selectedTag == 'all' || verse.tag.toLowerCase() == _selectedTag;
      final matchesSearch =
          query.isEmpty ||
          verse.scriptureText.toLowerCase().contains(query) ||
          verse.reference.toLowerCase().contains(query) ||
          (verse.note != null && verse.note!.toLowerCase().contains(query));
      return matchesTag && matchesSearch;
    }).toList();
  }

  void _removeVerse(String id) {
    setState(() {
      _verses.removeWhere((item) => item.id == id);
    });
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedTag = 'all';
    });
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
            Image.network(
              'https://lh3.googleusercontent.com/aida/AEtjO1W3jnvO55adWVwmyKUJh2se5gI4M-sgs1VUFkCXYcrGvFkmdREF4j5YcVqbht9_3tTOg1425qBi91QMQQOALRM8-39V5zTSUm_Pp31O93CPRHlEh59Irf3Hea766Yh1GgNgcRf1CqwQAFDG8u2Gp3KYgVvxiT3rBQATndImrJMgDFEAE1cl4GkHoVE2H657Gbl7qsICooTXOl7fGZ7J6P1ltGTt3e8V16KGWCDE4tkpEwAe7QPS7QIfplc',
              height: 28,
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
              backgroundImage: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuDci-_WOg-hpWXPdt5HZIv-ZHsdh4ejURS6gfzzIFk-zxjctnx7Pp-1rgbuB4A6gj_DKvzapUNgTYZuyFjrv7846J8Fb8CM5LTgP__PmM0v6r7_Io7wFWOCtYj35FrbpTiClLy4c2B34xMDvvSCmQ-QyDOsdOzAcFeptBDBfhPfyyGD-6IQ2btdHKIJjpnk9Kxf8pwDe62ZdxIOKLtLY5fMwpmAwLq9u3ypWJ3iPQ6yDIDuQ-vbDs36',
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
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBIHG2e2Y4fiThLzxqwwpjapselgMNV_iEO422k0HdCvTPkpbXJWxbWDVPn4Qlb2pPhyRJdd9ctbm4xs_37duuLasJEzkN8DaGsvFTv9lwFme8g7VxV5VZ4AnBe7_oqejfZRuMtzzQHgK6rBu4nqSaRqwuO-X-JyvGO-AhumLrAhmYV4PLomDY_JpPHD3q80S0nMHZt1jynDEMhPrLPLKbh06HadzBbZMbgP0c9VGPNkQw0_ZlAhQLX',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
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
                  hintText: 'Buscar citas, libros o notas...',
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

            // Chips Filtros Horizontales
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _tags.map((tag) {
                  final isSelected = _selectedTag == tag;
                  final label = tag == 'all'
                      ? 'Todos'
                      : '${tag[0].toUpperCase()}${tag.substring(1)}';

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(label),
                          if (isSelected) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.secondaryContainer,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedTag = tag);
                        }
                      },
                      selectedColor: AppColors.primaryContainer,
                      backgroundColor: AppColors.surfaceContainerLowest,
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.onPrimary
                            : AppColors.onSurfaceVariant,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide.none,
                      elevation: 1,
                    ),
                  );
                }).toList(),
              ),
            ),

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
            'No hay pasajes en esta categoría',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Explora la Biblia y pulsa la estrella en tus versículos preferidos para conservarlos aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _resetFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Ver todos los favoritos'),
          ),
        ],
      ),
    );
  }
}
