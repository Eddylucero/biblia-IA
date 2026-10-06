import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SuggestedPrompts extends StatelessWidget {
  final Function(String) onPromptSelect;

  const SuggestedPrompts({super.key, required this.onPromptSelect});

  static const List<String> _prompts = [
    '¿Cómo puedo fortalecer mi fe?',
    '¿Qué dice sobre el perdón?',
    'Salmos para la noche',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.lightbulb_outline, size: 15, color: AppColors.secondary),
            SizedBox(width: 6),
            Text(
              'Preguntas sugeridas',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _prompts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final prompt = _prompts[index];
              return ActionChip(
                label: Text(prompt),
                labelStyle: const TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                backgroundColor: AppColors.surfaceContainerLowest,
                elevation: 1,
                shadowColor: Colors.black.withValues(alpha: 0.05),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onPressed: () => onPromptSelect(prompt),
              );
            },
          ),
        ),
      ],
    );
  }
}
