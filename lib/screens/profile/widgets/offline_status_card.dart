import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class OfflineStatusCard extends StatelessWidget {
  final String storageUsed;
  final VoidCallback onManageDownloads;

  const OfflineStatusCard({
    super.key,
    required this.storageUsed,
    required this.onManageDownloads,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
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
    );
  }
}
