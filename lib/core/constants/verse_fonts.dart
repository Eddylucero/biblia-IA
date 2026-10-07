import 'package:flutter/material.dart';

class VerseFont {
  /// Familia declarada en `pubspec.yaml`.
  final String family;

  /// Nombre que ve la persona en el selector.
  final String label;

  /// Multiplicador del tamaño base.
  final double sizeFactor;

  /// Interlineado.
  final double height;

  /// Espaciado entre letras, como fracción del tamaño de fuente.
  final double letterSpacingFactor;

  const VerseFont({
    required this.family,
    required this.label,
    this.sizeFactor = 1,
    this.height = 1.45,
    this.letterSpacingFactor = 0,
  });

  static const String quoteFamily = 'VerseClassic';
  static const String captionFamily = 'VerseModern';

  static const List<VerseFont> all = [
    VerseFont(family: 'VerseClassic', label: 'Clásica', height: 1.45),
    VerseFont(
      family: 'VerseModern',
      label: 'Moderna',
      sizeFactor: 0.9,
      height: 1.4,
      letterSpacingFactor: -0.01,
    ),
    VerseFont(
      family: 'VerseStrong',
      label: 'Fuerte',
      sizeFactor: 1.08,
      height: 1.18,
      letterSpacingFactor: 0.01,
    ),
    VerseFont(
      family: 'VerseTypewriter',
      label: 'Máquina',
      sizeFactor: 0.86,
      height: 1.5,
    ),
    VerseFont(
      family: 'VerseHandwritten',
      label: 'Manuscrita',
      sizeFactor: 0.95,
      height: 1.6,
    ),
    VerseFont(
      family: 'VerseCalligraphy',
      label: 'Caligrafía',
      sizeFactor: 1.3,
      height: 1.35,
    ),
  ];

  /// Estilo del versículo para un tamaño ya resuelto.
  TextStyle verseStyle({required double fontSize, required double blurRadius}) {
    return TextStyle(
      fontFamily: family,
      fontSize: fontSize,
      height: height,
      letterSpacing: fontSize * letterSpacingFactor,
      color: Colors.white,
      shadows: [
        Shadow(
          color: Colors.black.withValues(alpha: 0.55),
          blurRadius: blurRadius,
          offset: Offset(0, blurRadius * 0.14),
        ),
      ],
    );
  }
}
