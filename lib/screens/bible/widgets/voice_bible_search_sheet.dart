import 'dart:async';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/book_model.dart';
import '../../../repositories/bible_repository.dart';

class VoiceBibleReference {
  final BookModel book;
  final int chapter;
  final int verse;

  const VoiceBibleReference({
    required this.book,
    required this.chapter,
    required this.verse,
  });
}

String _normalizeSpanish(String value) {
  const accented = 'áéíóúüñ';
  const plain = 'aeiouun';
  var normalized = value.toLowerCase();
  for (var index = 0; index < accented.length; index++) {
    normalized = normalized.replaceAll(accented[index], plain[index]);
  }
  return normalized
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
}

const _spanishNumbers = <String, int>{
  'cero': 0,
  'un': 1,
  'uno': 1,
  'una': 1,
  'dos': 2,
  'tres': 3,
  'cuatro': 4,
  'cinco': 5,
  'seis': 6,
  'siete': 7,
  'ocho': 8,
  'nueve': 9,
  'diez': 10,
  'once': 11,
  'doce': 12,
  'trece': 13,
  'catorce': 14,
  'quince': 15,
  'dieciseis': 16,
  'diecisiete': 17,
  'dieciocho': 18,
  'diecinueve': 19,
  'veinte': 20,
  'veintiuno': 21,
  'veintiun': 21,
  'veintiuna': 21,
  'veintidos': 22,
  'veintitres': 23,
  'veinticuatro': 24,
  'veinticinco': 25,
  'veintiseis': 26,
  'veintisiete': 27,
  'veintiocho': 28,
  'veintinueve': 29,
  'treinta': 30,
  'cuarenta': 40,
  'cincuenta': 50,
  'sesenta': 60,
  'setenta': 70,
  'ochenta': 80,
  'noventa': 90,
  'cien': 100,
  'ciento': 100,
};

int? _parseSpanishNumber(List<String> tokens, int start) {
  final token = tokens[start];
  final digit = int.tryParse(token);
  if (digit != null) return digit;
  final direct = _spanishNumbers[token];
  if (direct != null) {
    if (direct >= 30 &&
        direct < 100 &&
        start + 2 < tokens.length &&
        tokens[start + 1] == 'y') {
      final unit = _spanishNumbers[tokens[start + 2]];
      if (unit != null && unit > 0 && unit < 10) return direct + unit;
    }
    return direct;
  }
  if (token.startsWith('veinti')) {
    final suffix = token.substring('veinti'.length);
    final unit = _spanishNumbers[suffix];
    if (unit != null && unit > 0 && unit < 10) return 20 + unit;
  }
  return null;
}

VoiceBibleReference? parseVoiceBibleReference(
  String transcript,
  List<BookModel> books,
) {
  final normalizedTranscript = ' ${_normalizeSpanish(transcript)} ';
  if (normalizedTranscript.trim().isEmpty) return null;

  final aliases = <({BookModel book, String alias})>[];
  for (final book in books) {
    final names = <String>{
      _normalizeSpanish(book.name),
      _normalizeSpanish(book.modernName),
    }..remove('');
    for (final name in names) {
      aliases.add((book: book, alias: name));
      if (RegExp(r'^[123] ').hasMatch(name)) {
        final number = name.substring(0, 1);
        final ordinal = switch (number) {
          '1' => 'primera',
          '2' => 'segunda',
          _ => 'tercera',
        };
        final suffix = name.substring(2);
        aliases.add((book: book, alias: '$ordinal de $suffix'));
        aliases.add((book: book, alias: '$number de $suffix'));
      }
    }
  }
  aliases.sort(
    (left, right) => right.alias.length.compareTo(left.alias.length),
  );

  for (final entry in aliases) {
    final aliasWithBoundaries = ' ${entry.alias} ';
    final aliasStart = normalizedTranscript.indexOf(aliasWithBoundaries);
    if (aliasStart < 0) continue;
    final remainder = normalizedTranscript
        .substring(aliasStart + aliasWithBoundaries.length)
        .trim();
    final tokens = remainder
        .split(' ')
        .where(
          (token) =>
              token != 'capitulo' &&
              token != 'cap' &&
              token != 'versiculo' &&
              token != 'verso' &&
              token != 'numero' &&
              token != 'el',
        )
        .toList(growable: false);
    final numbers = <int>[];
    for (var index = 0; index < tokens.length; index++) {
      final number = _parseSpanishNumber(tokens, index);
      if (number == null) continue;
      numbers.add(number);
      if (index + 2 < tokens.length &&
          _spanishNumbers[tokens[index]] != null &&
          _spanishNumbers[tokens[index]]! >= 30 &&
          tokens[index + 1] == 'y') {
        index += 2;
      }
      if (numbers.length == 2) break;
    }

    // Si este libro no trae capítulo y versículo válidos seguimos con los
    // demás alias en vez de abandonar la frase entera.
    if (numbers.length < 2) continue;
    final chapter = numbers[0];
    final verse = numbers[1];
    if (chapter < 1 ||
        chapter > entry.book.chaptersCount ||
        verse < 1 ||
        verse > 200) {
      continue;
    }
    return VoiceBibleReference(
      book: entry.book,
      chapter: chapter,
      verse: verse,
    );
  }
  return null;
}

class VoiceBibleSearchSheet extends StatefulWidget {
  final List<BookModel> books;
  final BibleDataSource dataSource;
  final void Function(VoiceBibleReference reference) onReferenceSelected;
  final bool autoStartListening;

  const VoiceBibleSearchSheet({
    super.key,
    required this.books,
    required this.dataSource,
    required this.onReferenceSelected,
    this.autoStartListening = true,
  });

  @override
  State<VoiceBibleSearchSheet> createState() => _VoiceBibleSearchSheetState();
}

class _VoiceBibleSearchSheetState extends State<VoiceBibleSearchSheet> {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitializing = false;
  bool _isListening = false;
  bool _isValidating = false;
  String _transcription = '';
  String? _message;
  String? _spanishLocaleId;
  String? _interpretedTranscription;
  Timer? _finishFallback;

  @override
  void initState() {
    super.initState();
    if (widget.autoStartListening) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_startListening());
      });
    }
  }

  @override
  void dispose() {
    _finishFallback?.cancel();
    if (_speechToText.isListening) unawaited(_speechToText.cancel());
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
      return;
    }
    await _startListening();
  }

  Future<void> _startListening() async {
    if (_isInitializing || _isValidating || _speechToText.isListening) return;
    setState(() {
      _isInitializing = true;
      _message = null;
      _transcription = '';
    });
    _interpretedTranscription = null;
    _finishFallback?.cancel();
    try {
      final available = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
      );
      if (!mounted) return;
      if (!available) {
        setState(() {
          _message = 'No se pudo activar el micrófono. Revisa sus permisos.';
        });
        return;
      }
      _speechToText.statusListener = _onSpeechStatus;
      _speechToText.errorListener = _onSpeechError;

      final localeId = await _findSpanishLocale();
      if (localeId == null) {
        if (mounted) {
          setState(() => _message = 'No hay reconocimiento de voz en español.');
        }
        return;
      }

      setState(() {
        _message = 'Di el libro, capítulo y versículo; esperaré tu pausa.';
      });
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenOptions: SpeechListenOptions(
          localeId: localeId,
          listenMode: ListenMode.search,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          // Android marca TODOS sus errores como permanentes (incluido el
          // `error_no_match` que llega al terminar de hablar). Con
          // `cancelOnError: true` el plugin cancelaba la sesión y descartaba
          // el resultado final, así que la transcripción nunca se buscaba.
          cancelOnError: false,
          contextualPhrases: widget.books
              .expand((book) => [book.name, book.modernName])
              .toList(growable: false),
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(
          () => _message = 'No se pudo iniciar el micrófono. Intenta otra vez.',
        );
      }
    } finally {
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  Future<String?> _findSpanishLocale() async {
    if (_spanishLocaleId != null) return _spanishLocaleId;
    try {
      final locales = await _speechToText.locales();
      for (final locale in locales) {
        if (locale.localeId.toLowerCase().startsWith('es')) {
          _spanishLocaleId = locale.localeId;
          return _spanishLocaleId;
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  void _onSpeechStatus(String status) {
    if (!mounted) return;
    final isListening = status == SpeechToText.listeningStatus;
    setState(() => _isListening = isListening);
    if (!isListening && _transcription.isNotEmpty) {
      _finishFallback?.cancel();
      _finishFallback = Timer(const Duration(milliseconds: 500), () {
        if (mounted && !_speechToText.isListening) {
          unawaited(_interpretTranscription());
        }
      });
    }
  }

  void _onSpeechError(SpeechRecognitionError error) {
    if (!mounted) return;
    _finishFallback?.cancel();
    // Si ya hay transcripción, el error no es un fallo: Android avisa
    // `error_no_match` / `error_speech_timeout` al cerrar el micrófono aunque
    // haya reconocido texto. Interpretamos lo que escuchamos en vez de
    // descartarlo.
    if (_transcription.trim().isNotEmpty) {
      setState(() => _isListening = false);
      unawaited(_interpretTranscription());
      return;
    }
    setState(() {
      _isListening = false;
      _message = _speechErrorMessage(error);
    });
  }

  String _speechErrorMessage(SpeechRecognitionError error) {
    switch (error.errorMsg) {
      case 'error_no_match':
      case 'error_speech_timeout':
        return 'No te escuché. Toca el micrófono y di, por ejemplo: «Juan tres dieciséis».';
      case 'error_permission':
        return 'Necesito permiso para usar el micrófono. Actívalo en los ajustes.';
      case 'error_network':
      case 'error_network_timeout':
      case 'error_server':
      case 'error_server_disconnected':
        return 'El reconocimiento de voz necesita conexión. Revisa tu internet.';
      case 'error_busy':
        return 'El micrófono está ocupado. Espera un momento y reintenta.';
      case 'error_language_not_supported':
      case 'error_language_unavailable':
        return 'Este dispositivo no tiene el español descargado para dictado.';
      default:
        return 'No pude reconocer la voz. Toca el micrófono para reintentar.';
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) return;
    setState(() {
      _transcription = result.recognizedWords;
      _isListening = !result.finalResult;
      _message = result.finalResult
          ? 'Interpretando la referencia…'
          : 'Escuchando y transcribiendo…';
    });
    if (result.finalResult) {
      _finishFallback?.cancel();
      unawaited(_interpretTranscription());
    }
  }

  Future<void> _interpretTranscription() async {
    if (_isValidating) return;
    final transcription = _transcription.trim();
    // El resultado final, el error y el temporizador de respaldo pueden llegar
    // casi juntos; interpretamos una sola vez cada frase.
    if (transcription.isEmpty || transcription == _interpretedTranscription) {
      return;
    }
    _interpretedTranscription = transcription;
    final reference = parseVoiceBibleReference(transcription, widget.books);
    if (reference == null) {
      if (mounted) {
        setState(() {
          _isListening = false;
          _message =
              'No reconocí libro, capítulo y versículo. Prueba, por ejemplo: «Juan, capítulo tres, versículo dieciséis». El modal seguirá abierto.';
        });
      }
      return;
    }

    setState(() {
      _isValidating = true;
      _isListening = false;
      _message =
          'Verificando ${reference.book.name} ${reference.chapter}:${reference.verse}…';
    });
    try {
      final verses = await widget.dataSource.getChapterVerses(
        bookId: reference.book.id,
        chapter: reference.chapter,
      );
      if (!mounted) return;
      if (!verses.any((verse) => verse.verse == reference.verse)) {
        setState(() {
          _message =
              'No encontré ese versículo. Repite libro, capítulo y versículo.';
        });
        return;
      }
      Navigator.of(context).pop();
      widget.onReferenceSelected(reference);
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _message = 'No pude verificar la referencia. Inténtalo otra vez.',
        );
      }
    } finally {
      if (mounted) setState(() => _isValidating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.outline.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Buscar una referencia',
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Cerrar',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              constraints: const BoxConstraints(minHeight: 88),
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isListening
                      ? AppColors.secondaryFixedDim
                      : AppColors.outlineVariant,
                ),
              ),
              child: Text(
                _transcription.isEmpty
                    ? 'La transcripción aparecerá aquí mientras hablas.'
                    : _transcription,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _transcription.isEmpty
                      ? AppColors.onSurfaceVariant
                      : AppColors.onSurface,
                  fontSize: 17,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (_message != null)
              Text(
                _message!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            const SizedBox(height: 14),
            SizedBox(
              width: 58,
              height: 58,
              child: IconButton.filled(
                tooltip: _isListening ? 'Detener escucha' : 'Volver a escuchar',
                onPressed: _isInitializing || _isValidating
                    ? null
                    : _toggleListening,
                style: IconButton.styleFrom(
                  backgroundColor: _isListening
                      ? AppColors.error
                      : AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                ),
                icon: _isInitializing || _isValidating
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : Icon(_isListening ? Icons.stop : Icons.mic, size: 26),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
