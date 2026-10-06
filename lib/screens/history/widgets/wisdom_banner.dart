import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class WisdomBanner extends StatelessWidget {
  final int totalPassages;
  final String topic;

  const WisdomBanner({
    super.key,
    required this.totalPassages,
    this.topic = 'consuelo y esperanza',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryContainer,
            AppColors.tertiaryContainer,
            AppColors.primaryContainer,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.secondaryFixed.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              size: 20,
              color: AppColors.secondaryFixed,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SABIDURÍA ACUMULADA',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryFixed,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Has explorado $totalPassages pasajes sobre $topic este mes.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.primaryFixedDim,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
