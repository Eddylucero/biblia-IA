import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class QuickAccessSection extends StatelessWidget {
  const QuickAccessSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EXPLORACIÓN Y RECURSOS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        _buildTile(
          icon: Icons.search,
          title: 'Buscar en la Biblia',
          subtitle: 'Palabras clave, libros y concordancias',
          iconBg: AppColors.surfaceContainerLow,
          iconColor: AppColors.primaryContainer,
        ),
        const SizedBox(height: 10),
        _buildTile(
          icon: Icons.star,
          title: 'Colección de Versículos',
          subtitle: 'Pasajes diarios, favoritos y destacados',
          iconBg: AppColors.secondaryContainer.withValues(alpha: 0.4),
          iconColor: AppColors.secondary,
        ),
        const SizedBox(height: 10),
        _buildTile(
          icon: Icons.history,
          title: 'Historial de Preguntas',
          subtitle: 'Tus diálogos y reflexiones guardadas',
          iconBg: AppColors.surfaceContainerLow,
          iconColor: AppColors.primaryContainer,
          badgeText: '12',
        ),
      ],
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBg,
    required Color iconColor,
    String? badgeText,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
          ),
          if (badgeText != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          const Icon(Icons.chevron_right, color: AppColors.outline, size: 20),
        ],
      ),
    );
  }
}
