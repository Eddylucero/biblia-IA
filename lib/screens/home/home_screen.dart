import 'dart:async';
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
            const ReflectionCard(),
            const SizedBox(height: 24),
            const QuickAccessSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String greetingText;
    String emoji;

    if (hour >= 5 && hour < 12) {
      greetingText = 'Buenos días';
      emoji = '🌅';
    } else if (hour >= 12 && hour < 19) {
      greetingText = 'Buenas tardes';
      emoji = '☀️';
    } else {
      greetingText = 'Buenas noches';
      emoji = '🌙';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              greetingText,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 6),
            Text(emoji, style: const TextStyle(fontSize: 16)),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
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
}

class ReflectionCard extends StatefulWidget {
  const ReflectionCard({super.key});

  @override
  State<ReflectionCard> createState() => _ReflectionCardState();
}

class _ReflectionCardState extends State<ReflectionCard> {
  // Lista de imágenes de fondo
  final List<String> _images = [
    'assets/reflexiones/refle-1.jpeg',
    'assets/reflexiones/refle-2.jpeg',
    'assets/reflexiones/refle-3.jpeg',
    'assets/reflexiones/refle-4.jpeg',
    'assets/reflexiones/refle-5.jpeg',
  ];

  // Lista de textos de reflexiones
  final List<String> _reflections = [
    'Dios tiene un propósito\nen cada etapa de tu vida',
    'Aprender a confiar en Dios\naunque no tengas todas las respuestas',
    'Dios está contigo\nen los momentos más difíciles',
    'Los tiempos de espera\ntambién forman parte del propósito de Dios',
    'Cuando una puerta se cierra,\nDios puede estar guiándote hacia algo mejor',
    'Encontrar esperanza\nen medio de las dificultades',
    'Dios renueva tus fuerzas\ncuando sientes que ya no puedes más',
    'Dejar en manos de Dios\nlo que no puedes controlar',
    'Reconocer las bendiciones\nen las cosas sencillas de cada día',
    'Seguir adelante con fe\naunque el camino todavía no sea claro',
  ];

  late int _currentImageIndex;
  late String _todayReflection;
  bool _isPlaying = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;

    _todayReflection = _reflections[dayOfYear % _reflections.length];

    _currentImageIndex = dayOfYear % _images.length;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _togglePlayState() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _startImageRotation();
    } else {
      _timer?.cancel();
    }
  }

  void _startImageRotation() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (!mounted) return;
      setState(() {
        // Solo rotamos el índice de las imágenes de fondo
        _currentImageIndex = (_currentImageIndex + 1) % _images.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Transición suave SOLO para las imágenes de fondo
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            child: Image.asset(
              _images[_currentImageIndex],
              key: ValueKey<String>(_images[_currentImageIndex]),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: AppColors.primaryContainer),
            ),
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
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'REFLEXIÓN DIARIA',
                            style: TextStyle(
                              color: AppColors.secondaryFixed,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          if (_isPlaying) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.secondaryFixed,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      // La frase de la reflexión queda fija durante el día
                      Text(
                        _todayReflection,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _togglePlayState,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _isPlaying
                          ? AppColors.secondaryFixed
                          : Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: AnimatedIcon(
                        icon: AnimatedIcons.play_pause,
                        progress: AlwaysStoppedAnimation(
                          _isPlaying ? 1.0 : 0.0,
                        ),
                        color: _isPlaying
                            ? AppColors.primaryContainer
                            : Colors.white,
                        size: 20,
                      ),
                    ),
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
