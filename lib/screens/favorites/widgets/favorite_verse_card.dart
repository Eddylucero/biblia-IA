import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class FavoriteVerseCard extends StatelessWidget {
  final String tag;
  final String date;
  final String scriptureText;
  final String reference;
  final String version;
  final Color accentColor;
  final Widget? bottomAction;
  final VoidCallback onDismiss;
  final VoidCallback? onShare;

  const FavoriteVerseCard({
    super.key,
    required this.tag,
    required this.date,
    required this.scriptureText,
    required this.reference,
    this.version = 'RVR1960',
    this.accentColor = AppColors.secondary,
    this.bottomAction,
    required this.onDismiss,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Borde acentuado a la izquierda
          Positioned(
            left: 0,
            top: 24,
            bottom: 24,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera: Tag, Fecha y Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryFixed,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSecondaryFixed,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: AppColors.outline,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              date,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.outline,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.star,
                            color: AppColors.secondary,
                            size: 20,
                          ),
                          onPressed: () {},
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.share_outlined,
                            color: AppColors.onSurfaceVariant,
                            size: 19,
                          ),
                          onPressed: onShare ?? () {},
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.bookmark_remove_outlined,
                            color: AppColors.onSurfaceVariant,
                            size: 19,
                          ),
                          onPressed: onDismiss,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Texto de la Escritura
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '«$scriptureText»',
                        style: const TextStyle(
                          fontFamily: 'Newsreader',
                          fontSize: 18,
                          height: 1.5,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          text: reference,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                          children: [
                            TextSpan(
                              text: ' • $version',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: AppColors.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (bottomAction != null) ...[
                  const SizedBox(height: 12),
                  bottomAction!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
