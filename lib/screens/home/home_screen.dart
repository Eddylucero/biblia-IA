import 'package:flutter/material.dart';
import '../../repositories/bible_repository.dart';
import '../../core/constants/app_colors.dart';
import 'widgets/ai_prompt_card.dart';
import 'widgets/daily_verse_card.dart';
import 'widgets/quick_access_section.dart';

class HomeScreen extends StatelessWidget {
  final BibleDataSource? dataSource;

  const HomeScreen({super.key, this.dataSource});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64.0),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.auto_stories,
                        color: AppColors.secondaryFixed,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Inicio',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.search,
                        color: AppColors.onSurfaceVariant,
                      ),
                      onPressed: () {},
                    ),
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.surfaceContainerLow,
                      child: Icon(
                        Icons.person,
                        size: 20,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _buildGreeting(),
            const SizedBox(height: 20),
            AiPromptCard(dataSource: dataSource),
            const SizedBox(height: 24),
            DailyVerseCard(dataSource: dataSource),
            const SizedBox(height: 20),
            _buildReflectionCard(),
            const SizedBox(height: 24),
            const QuickAccessSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Buenos días',
              style: TextStyle(fontSize: 15, color: AppColors.onSurfaceVariant),
            ),
            SizedBox(width: 6),
            Text('👋', style: TextStyle(fontSize: 16)),
          ],
        ),
        SizedBox(height: 4),
        Text(
          '¿Qué quieres consultar hoy?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildReflectionCard() {
    return Container(
      height: 140,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuA0NvjFoAFNhf7QAO9bzKaT_JuytgcZVZOPxTYNzTQv4lfEzS-jLXB9vUSMiEdo2na2HUp6C2AQLv7b1eydy1l3SM9uPOk1DESE_mBhpTh5JkxQKJgmV31-gBr3ULPc41VfNbm_W8rxcVwhbydrwh_IoEbnrOigQDUUxS47s_UGwRhrb7yKlH-_EU8x-EKMzaUmexFLscTklck3N4i7zkL0GWqw7LwgoU2TZqum_8kXiO6wNz2TbHin',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(color: AppColors.primaryContainer),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors.primaryContainer.withValues(alpha: 0.9),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REFLEXIÓN DIARIA',
                      style: TextStyle(
                        color: AppColors.secondaryFixed,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'La serenidad en tiempos\nde incertidumbre',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
