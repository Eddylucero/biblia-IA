import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'widgets/history_card.dart';
import 'widgets/wisdom_banner.dart';

class HistoryItem {
  final String id;
  final String timeframe; // 'semana' | 'mes'
  final String dateText;
  final String title;
  final String previewText;
  final int versesCount;
  final String keywords;
  bool isStarred;
  final bool hasExegesis;

  HistoryItem({
    required this.id,
    required this.timeframe,
    required this.dateText,
    required this.title,
    required this.previewText,
    required this.versesCount,
    required this.keywords,
    this.isStarred = false,
    this.hasExegesis = false,
  });
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = 'all'; // 'all', 'saved', 'exegesis'

  final List<HistoryItem> _items = [
    HistoryItem(
      id: 'h1',
      timeframe: 'semana',
      dateText: 'Hoy, 09:42 AM',
      title: '¿Qué dice la Biblia sobre el miedo y la ansiedad?',
      previewText:
          'Dios nos invita a depositar nuestras cargas en Él, prometiendo una paz que sobrepasa todo entendimiento (Isaías 41:10, Filipenses 4:6-7)...',
      versesCount: 3,
      keywords: 'miedo ansiedad isaias filipenses paz',
      isStarred: true,
      hasExegesis: true,
    ),
    HistoryItem(
      id: 'h2',
      timeframe: 'semana',
      dateText: 'Ayer, 06:15 PM',
      title: '¿Cómo puedo fortalecer mi fe en momentos de incertidumbre?',
      previewText:
          'La fe viene por el oír de la Palabra. La perseverancia en la oración y el refugio compartido en la comunidad renuevan continuamente el espíritu...',
      versesCount: 4,
      keywords: 'fortalecer fe incertidumbre oracion comunidad',
      isStarred: false,
      hasExegesis: false,
    ),
    HistoryItem(
      id: 'h3',
      timeframe: 'mes',
      dateText: '24 Septiembre • 04:20 PM',
      title:
          '¿Qué significa Mateo 6:34 cuando dice “basta a cada día su propio afán”?',
      previewText:
          'Es una invitación a vivir en el presente con confianza plena en la provisión divina cotidiana, liberando la mente de temores venideros...',
      versesCount: 2,
      keywords: 'mateo afan provision cotidiana presente vivir',
      isStarred: false,
      hasExegesis: true,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<HistoryItem> get _filteredItems {
    final query = _searchController.text.toLowerCase().trim();

    return _items.where((item) {
      // Filtro por Chips
      if (_activeFilter == 'saved' && !item.isStarred) return false;
      if (_activeFilter == 'exegesis' && !item.hasExegesis) return false;

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
          '¿Deseas vaciar todo el historial de conversaciones guardadas? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _items.clear();
              });
              Navigator.of(context).pop();
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
            // Sub-header Context
            const Row(
              children: [
                Icon(Icons.auto_stories, size: 18, color: AppColors.secondary),
                SizedBox(width: 6),
                Text(
                  'ARCHIVO TEOLÓGICO',
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
              'Tus diálogos y reflexiones guardadas con Biblia IA.',
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
                  hintText: 'Buscar en el historial de reflexiones...',
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
                  _buildFilterChip('exegesis', 'Con exégesis', Icons.menu_book),
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

              // Banner Sabiduría
              const WisdomBanner(totalPassages: 9),

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
                    'Tus consultas están cifradas en este dispositivo',
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
      onOpen: () {},
      onToggleStar: () {
        setState(() {
          item.isStarred = !item.isStarred;
        });
      },
      onDelete: () {
        setState(() {
          _items.removeWhere((e) => e.id == item.id);
        });
      },
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
            'No se encontraron diálogos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Prueba buscando con palabras clave como “paz”, “fe”, “oración” o citas de capítulos.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
