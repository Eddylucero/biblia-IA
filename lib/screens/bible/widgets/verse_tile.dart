import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class VerseTile extends StatelessWidget {
  final int number;
  final String text;
  final double fontSize;
  final bool isSelected;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback? onBookmark;
  final VoidCallback? onHighlight;
  final VoidCallback? onShare;

  const VerseTile({
    super.key,
    required this.number,
    required this.text,
    this.fontSize = 17,
    this.isSelected = false,
    this.isBookmarked = false,
    required this.onTap,
    this.onBookmark,
    this.onHighlight,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    if (!isSelected) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '$number',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: fontSize,
                    height: 1.8,
                    color: AppColors.onSurface,
                    fontFamily: 'Serif', // O tu fuente scripture-verse
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Estado Seleccionado con Menú Flotante
    return Column(
      children: [
        // Menú Contextual Flotante Elevado
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: isBookmarked
                    ? 'Quitar de favoritos'
                    : 'Agregar a favoritos',
                icon: Icon(
                  isBookmarked ? Icons.star : Icons.star_border,
                  size: 20,
                  color: Colors.white,
                ),
                onPressed: onBookmark,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
              IconButton(
                tooltip: 'Editar resaltado',
                icon: const Icon(
                  Icons.border_color,
                  size: 18,
                  color: Colors.white,
                ),
                onPressed: onHighlight,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
              IconButton(
                tooltip: 'Compartir versículo',
                icon: const Icon(Icons.share, size: 18, color: Colors.white),
                onPressed: onShare,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
            ],
          ),
        ),

        // Versículo Destacado con Borde Dorado
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(
              begin: AppColors.surfaceContainerLowest,
              end: AppColors.secondaryFixed.withValues(alpha: 0.42),
            ),
            duration: const Duration(milliseconds: 520),
            curve: Curves.easeOutCubic,
            builder: (context, backgroundColor, child) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: const Border(
                  left: BorderSide(color: AppColors.secondary, width: 4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      '$number',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: fontSize,
                        height: 1.8,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                        fontFamily: 'Serif',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
