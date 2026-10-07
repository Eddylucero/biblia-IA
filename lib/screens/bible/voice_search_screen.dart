import 'dart:async';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/constants/app_colors.dart';
import '../../models/verse_model.dart';
import '../../repositories/bible_repository.dart';
import '../../repositories/question_history_repository.dart';

String limitVoiceSearchWords(String recognizedWords, {int maximumWords = 5}) {
  final words = recognizedWords
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty);
  return words.take(maximumWords).join(' ');
}

class VoiceSearchScreen extends StatefulWidget {
  final BibleDataSource? dataSource;
  final bool autoStartListening;

  const VoiceSearchScreen({
    super.key,
    this.dataSource,
    this.autoStartListening = false,
  });

  @override
  State<VoiceSearchScreen> createState() => _VoiceSearchScreenState();
}

class _VoiceSearchScreenState extends State<VoiceSearchScreen> {
  final SpeechToText _speechToText = SpeechToText();
  final QuestionHistoryRepository _historyRepository =
      QuestionHistoryRepository.instance;
  late final BibleDataSource _dataSource;
  bool _isInitializing = false;
  bool _isListening = false;
  bool _isSearching = false;
  String _transcription = '';
  String? _statusMessage;
  List<VerseModel> _results = const [];
  String? _spanishLocaleId;
  bool _hasSubmittedCurrentUtterance = false;
  Timer? _speechFinishFallback;

  @override
  void initState() {
    super.initState();
    _dataSource = widget.dataSource ?? BibleRepository();
    if (widget.autoStartListening) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_startListening());
      });
    }
  }

  @override
  void dispose() {
    _speechFinishFallback?.cancel();
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
    if (_isInitializing || _isSearching || _speechToText.isListening) return;
    setState(() {
      _isInitializing = true;
      _statusMessage = null;
      _results = const [];
      _transcription = '';
      _hasSubmittedCurrentUtterance = false;
    });
    _speechFinishFallback?.cancel();

    try {
      final available = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
      );
      if (!mounted) return;
      if (!available) {
        setState(() {
          _statusMessage =
              'No se pudo activar el reconocimiento de voz. Revisa el permiso del micrófono.';
        });
        return;
      }
      _speechToText.statusListener = _onSpeechStatus;
      _speechToText.errorListener = _onSpeechError;

      final localeId = await _findSpanishLocale();
      if (localeId == null) {
        if (mounted) {
          setState(() {
            _statusMessage =
                'No hay reconocimiento de voz en español disponible en este dispositivo.';
          });
        }
        return;
      }

      setState(() {
        _statusMessage = 'Di una frase corta; buscaré cuando hagas una pausa.';
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
          // el resultado final, así que la frase nunca se buscaba.
          cancelOnError: false,
          contextualPhrases: const [
            'Jesús',
            'Moisés',
            'Noé',
            'Génesis',
            'Salmos',
            'Evangelio',
          ],
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _statusMessage =
              'No se pudo iniciar el micrófono. Comprueba el permiso e inténtalo otra vez.';
        });
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
      _speechFinishFallback?.cancel();
      _speechFinishFallback = Timer(const Duration(milliseconds: 400), () {
        if (mounted &&
            !_speechToText.isListening &&
            !_hasSubmittedCurrentUtterance) {
          _finishVoiceSearch();
        }
      });
    }
  }

  void _onSpeechError(SpeechRecognitionError error) {
    if (!mounted) return;
    _speechFinishFallback?.cancel();
    // Si ya hay transcripción, el error no es un fallo: Android avisa
    // `error_no_match` / `error_speech_timeout` al cerrar el micrófono aunque
    // haya reconocido texto. Buscamos con lo que escuchamos.
    if (_transcription.trim().isNotEmpty && !_hasSubmittedCurrentUtterance) {
      setState(() => _isListening = false);
      _finishVoiceSearch();
      return;
    }
    setState(() {
      _isListening = false;
      _statusMessage = _speechErrorMessage(error);
    });
  }

  String _speechErrorMessage(SpeechRecognitionError error) {
    switch (error.errorMsg) {
      case 'error_no_match':
      case 'error_speech_timeout':
        return 'No te escuché. Toca el micrófono y di de 3 a 5 palabras clave.';
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
        return 'No pude reconocer la voz. Toca el micrófono para intentarlo de nuevo.';
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) return;
    final rawWords = result.recognizedWords
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList(growable: false);
    final query = limitVoiceSearchWords(result.recognizedWords);

    setState(() {
      _transcription = query;
      _isListening = !result.finalResult;
      _statusMessage = result.finalResult
          ? 'Buscando «$query»…'
          : 'Transcribiendo… ${rawWords.length > 5 ? 5 : rawWords.length}/5 palabras';
    });

    if (result.finalResult) {
      _speechFinishFallback?.cancel();
      if (query.isEmpty) {
        setState(() {
          _statusMessage = 'No alcancé a reconocer palabras. Intenta de nuevo.';
        });
        return;
      }
      _finishVoiceSearch();
    } else if (rawWords.length > 5) {
      setState(() {
        _statusMessage =
            'Ya capturé las primeras cinco palabras; termina tu frase.';
      });
    }
  }

  void _finishVoiceSearch() {
    if (_hasSubmittedCurrentUtterance) return;
    final query = limitVoiceSearchWords(_transcription);
    if (query.isEmpty) {
      setState(() {
        _isListening = false;
        _statusMessage =
            'No alcancé a reconocer palabras. Toca el micrófono para reintentar.';
      });
      return;
    }
    _hasSubmittedCurrentUtterance = true;
    _speechFinishFallback?.cancel();
    setState(() {
      _isListening = false;
      _statusMessage = 'Buscando «$query»…';
    });
    unawaited(_search(query));
  }

  Future<void> _search(String query) async {
    if (_isSearching) return;
    setState(() {
      _isSearching = true;
      _statusMessage = 'Buscando en la Biblia…';
    });
    try {
      final results = await _dataSource.searchVerses(query);
      try {
        await _historyRepository.add(query, results);
      } catch (_) {
        // The search remains useful if saving the history fails.
      }
      if (!mounted) return;
      setState(() {
        _results = results;
        _statusMessage = results.isEmpty
            ? 'No encontré coincidencias. Prueba con otras palabras.'
            : 'Resultados para «$query»';
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _statusMessage = 'No pude consultar la Biblia. Inténtalo de nuevo.';
        });
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _openVerse(VerseModel verse) {
    Navigator.of(context).pushNamed(
      '/chapter',
      arguments: {
        'bookName': verse.bookName,
        'chapterNumber': verse.chapter,
        'selectedVerseNumber': verse.verse,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        title: const Text('Buscar en la Biblia'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            const Text(
              'Búsqueda por voz',
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Di de 3 a 5 palabras clave. La búsqueda empieza cuando hagas una pausa.',
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 28),
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: _isListening
                      ? AppColors.secondary.withValues(alpha: 0.16)
                      : AppColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  tooltip: _isListening
                      ? 'Detener y buscar'
                      : 'Empezar a hablar',
                  onPressed: _isInitializing || _isSearching
                      ? null
                      : _toggleListening,
                  iconSize: 38,
                  color: _isListening ? AppColors.error : AppColors.secondary,
                  icon: _isInitializing
                      ? const SizedBox.square(
                          dimension: 30,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        )
                      : Icon(_isListening ? Icons.stop : Icons.mic),
                ),
              ),
            ),
            const SizedBox(height: 24),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              constraints: const BoxConstraints(minHeight: 112),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isListening
                      ? AppColors.secondaryFixedDim
                      : AppColors.outlineVariant,
                ),
              ),
              alignment: Alignment.centerLeft,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: Text(
                  _transcription.isEmpty
                      ? 'La transcripción aparecerá aquí mientras hablas.'
                      : _transcription,
                  key: ValueKey(
                    _transcription.isEmpty ? 'placeholder' : _transcription,
                  ),
                  style: TextStyle(
                    color: _transcription.isEmpty
                        ? AppColors.outline
                        : AppColors.onSurface,
                    fontSize: 18,
                    height: 1.45,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_statusMessage != null)
              Center(
                child: Text(
                  _statusMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            if (_isSearching) ...[
              const SizedBox(height: 18),
              const Center(child: CircularProgressIndicator()),
            ],
            if (_results.isNotEmpty) ...[
              const SizedBox(height: 24),
              for (final verse in _results)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () => _openVerse(verse),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${verse.bookName} ${verse.chapter}:${verse.verse}',
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              verse.text,
                              style: const TextStyle(
                                color: AppColors.onSurface,
                                fontSize: 15,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
