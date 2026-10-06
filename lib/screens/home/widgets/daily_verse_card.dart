import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DailyVerseCard extends StatelessWidget {
  const DailyVerseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'CONTINUAR LEYENDO',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
            Row(
              children: const [
                Icon(Icons.menu_book, size: 16, color: AppColors.secondary),
                SizedBox(width: 4),
                Text(
                  'Plan Diario',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 4, color: AppColors.secondary),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.light_mode,
                                    color: AppColors.secondary,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Versículo del día',
                                    style: TextStyle(
                                      color: AppColors.secondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.bookmark_border,
                              color: AppColors.onSurfaceVariant,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '«Todo lo puedo en Cristo que me fortalece.»',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 16,
                            height: 1.4,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Filipenses 4:13 ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurface,
                                      fontSize: 14,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '• RVR1960',
                                    style: TextStyle(
                                      color: AppColors.outline,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Row(
                              children: [
                                Text(
                                  'Leer capítulo',
                                  style: TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  color: AppColors.secondary,
                                  size: 16,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
