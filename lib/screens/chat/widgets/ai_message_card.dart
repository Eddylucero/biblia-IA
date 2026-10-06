import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class VerseItem {
  final String reference;
  final String category;
  final String text;

  const VerseItem({
    required this.reference,
    required this.category,
    required this.text,
  });
}

class AiMessageCard extends StatelessWidget {
  final String reflectionText;
  final List<VerseItem> verses;

  const AiMessageCard({
    super.key,
    required this.reflectionText,
    required this.verses,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI Header Meta
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.secondaryFixed,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 14,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Biblia IA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Exégesis · Reina-Valera 1960',
              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Content Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
              topLeft: Radius.circular(2),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryContainer.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Borde de acento litúrgico
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryFixed,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reflectionText,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sección de Pasajes
                    const Row(
                      children: [
                        Icon(
                          Icons.menu_book,
                          size: 16,
                          color: AppColors.secondary,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'PASAJES FUNDAMENTALES',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Lista de versículos
                    ...verses.map((v) => _buildVerseTile(v)),

                    const SizedBox(height: 16),

                    // Botones de acción inferiores
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.arrow_forward, size: 16),
                          label: const Text('Ver versículos completos'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryFixed,
                            foregroundColor: AppColors.onSurface,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(6),
                              icon: const Icon(Icons.content_copy, size: 18),
                              color: AppColors.onSurfaceVariant,
                              onPressed: () {},
                            ),
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(6),
                              icon: const Icon(Icons.bookmark_border, size: 18),
                              color: AppColors.onSurfaceVariant,
                              onPressed: () {},
                            ),
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(6),
                              icon: const Icon(Icons.share, size: 18),
                              color: AppColors.onSurfaceVariant,
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerseTile(VerseItem verse) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                verse.reference,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                verse.category,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '“${verse.text}”',
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 14,
              height: 1.4,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
