import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class FavoritesAudioCard extends StatelessWidget {
  final int totalVerses;
  final VoidCallback onPlay;

  const FavoritesAudioCard({
    super.key,
    required this.totalVerses,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBDhDGgqjTdaOf-oXhQUtw6AOq-CviesxZYLzshxVD961TuwZLPSX3mNA0CgHmLq7yFJ4dd473l28R8QI6IT5tnuzMP30bEaHYIfTfBvjBkRJCRPREOZRKUMVzxq9_ENCjwgsO-zCzeWMeW-fPyB5TV0TLaC90ZgIulCLWCNHr_xpNKc99qnZIP5Fsew4GTmcI_6COaPt5aMZt7Fp02_Dq_ROxKpiN6ykfYnpShqSOr2N6G6Nrs1hHR',
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Audio Devocional de Favoritos',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Reproducir tus $totalVerses pasajes con música suave',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: onPlay,
            icon: const Icon(Icons.play_arrow, size: 22),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
