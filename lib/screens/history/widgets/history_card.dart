import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class HistoryCard extends StatelessWidget {
  final String dateText;
  final String title;
  final String previewText;
  final int versesCount;
  final bool isStarred;
  final Color accentColor;
  final IconData categoryIcon;
  final VoidCallback onOpen;
  final VoidCallback onToggleStar;
  final VoidCallback onDelete;

  const HistoryCard({
    super.key,
    required this.dateText,
    required this.title,
    required this.previewText,
    required this.versesCount,
    this.isStarred = false,
    this.accentColor = AppColors.secondary,
    this.categoryIcon = Icons.psychology_alt,
    required this.onOpen,
    required this.onToggleStar,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Borde decorativo a la izquierda
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera: Icono, Fecha y Acciones
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 4),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isStarred
                                ? AppColors.secondaryFixed
                                : AppColors.surfaceContainerHigh,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            categoryIcon,
                            size: 16,
                            color: isStarred
                                ? AppColors.onSecondaryFixed
                                : AppColors.primaryContainer,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dateText,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isStarred ? Icons.star : Icons.star_border,
                            color: isStarred
                                ? AppColors.secondary
                                : AppColors.outline,
                            size: 20,
                          ),
                          onPressed: onToggleStar,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.outline,
                            size: 20,
                          ),
                          onPressed: onDelete,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Contenido principal
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        previewText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Pie de tarjeta: Versículos e interactivo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.menu_book,
                          size: 16,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$versesCount versículos citados',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: onOpen,
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: Text(
                        isStarred ? 'Abrir conversación' : 'Reanudar diálogo',
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: isStarred
                            ? AppColors.primaryContainer
                            : AppColors.surfaceContainerHigh,
                        foregroundColor: isStarred
                            ? AppColors.onPrimary
                            : AppColors.primaryContainer,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
