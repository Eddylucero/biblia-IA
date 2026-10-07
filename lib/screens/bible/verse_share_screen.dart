import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/assets/background_catalog.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/verse_fonts.dart';
import '../../core/sharing/verse_image_exporter.dart';

/// Compositor de imágenes: coloca el versículo seleccionado sobre los fondos de
/// `assets/fondos-img/`, permite deslizar entre ellos, mover el texto, cambiar
/// la tipografía y luego compartir la imagen o descargarla a la galería.
class VerseShareScreen extends StatefulWidget {
  final String reference;
  final String verseText;

  const VerseShareScreen({
    super.key,
    required this.reference,
    required this.verseText,
  });

  @override
  State<VerseShareScreen> createState() => _VerseShareScreenState();
}

class _VerseShareScreenState extends State<VerseShareScreen> {
  static const Color _canvas = Color(0xFF0E1622);
  static const double _thumbSize = 52;
  static const double _thumbGap = 10;
  static const double _thumbPadding = 16;

  /// Desplazamiento máximo del texto, como fracción del lado de la tarjeta.
  static const double _maxShift = 0.35;

  static const double _minFontScale = 0.5;
  static const double _maxFontScale = 1.4;
  static const double _fontScaleStep = 0.1;

  /// Orden en que rota el botón de alineación.
  static const List<TextAlign> _alignments = [
    TextAlign.center,
    TextAlign.left,
    TextAlign.right,
  ];

  /// Umbral para que el texto se quede pegado al centro.
  static const double _snapThreshold = 0.012;

  final PageController _pageController = PageController(viewportFraction: 0.88);
  final ScrollController _thumbController = ScrollController();
  final Map<int, GlobalKey> _boundaryKeys = <int, GlobalKey>{};

  List<String> _backgrounds = const <String>[];
  bool _isLoading = true;
  bool _isBusy = false;
  bool _isMovingText = false;
  int _index = 0;
  double _fontScale = 1;
  VerseFont _font = VerseFont.all.first;
  TextAlign _textAlign = TextAlign.center;
  Offset _textShift = Offset.zero;
  Offset _shiftAtDragStart = Offset.zero;

  @override
  void initState() {
    super.initState();
    _loadBackgrounds();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _thumbController.dispose();
    super.dispose();
  }

  Future<void> _loadBackgrounds() async {
    final backgrounds = await BackgroundCatalog.load();
    if (!mounted) return;
    setState(() {
      _backgrounds = backgrounds;
      _isLoading = false;
    });
    _precacheAround(0);
  }

  void _precacheAround(int index) {
    for (final neighbour in <int>[index, index - 1, index + 1]) {
      if (neighbour < 0 || neighbour >= _backgrounds.length) continue;
      precacheImage(AssetImage(_backgrounds[neighbour]), context);
    }
  }

  void _onPageChanged(int index) {
    setState(() => _index = index);
    _precacheAround(index);
    _syncThumbnails(index);
  }

  void _goToBackground(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 340),
      curve: Curves.easeOutCubic,
    );
  }

  void _syncThumbnails(int index) {
    if (!_thumbController.hasClients) return;
    const extent = _thumbSize + _thumbGap;
    final position = _thumbController.position;
    final target =
        _thumbPadding +
        (index * extent) +
        (extent / 2) -
        (position.viewportDimension / 2);
    _thumbController.animateTo(
      target.clamp(position.minScrollExtent, position.maxScrollExtent),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  void _changeFontScale(double delta) {
    final next = (_fontScale + delta).clamp(_minFontScale, _maxFontScale);
    if (next == _fontScale) return;
    setState(() => _fontScale = next);
  }

  /// Rota entre centrado, alineado a la izquierda y alineado a la derecha.
  void _cycleTextAlign() {
    final next =
        _alignments[(_alignments.indexOf(_textAlign) + 1) % _alignments.length];
    setState(() => _textAlign = next);
  }

  ({IconData icon, String label}) get _alignHint => switch (_textAlign) {
    TextAlign.left => (
      icon: Icons.format_align_left,
      label: 'Texto a la izquierda',
    ),
    TextAlign.right => (
      icon: Icons.format_align_right,
      label: 'Texto a la derecha',
    ),
    _ => (icon: Icons.format_align_center, label: 'Texto centrado'),
  };

  void _selectFont(VerseFont font) {
    if (font.family == _font.family) return;
    setState(() => _font = font);
  }

  void _onTextDragStart() {
    HapticFeedback.selectionClick();
    setState(() {
      _isMovingText = true;
      _shiftAtDragStart = _textShift;
    });
  }

  /// [moved] es el acumulado desde donde empezó el toque, como fracción del
  /// lado de la tarjeta, así el movimiento se ve igual en pantalla y en el PNG.
  void _onTextDragUpdate(Offset moved) {
    var next = Offset(
      (_shiftAtDragStart.dx + moved.dx).clamp(-_maxShift, _maxShift),
      (_shiftAtDragStart.dy + moved.dy).clamp(-_maxShift, _maxShift),
    );
    if (next.dx.abs() < _snapThreshold) next = Offset(0, next.dy);
    if (next.dy.abs() < _snapThreshold) next = Offset(next.dx, 0);
    if (next == _textShift) return;
    setState(() => _textShift = next);
  }

  void _onTextDragEnd() {
    if (!_isMovingText) return;
    setState(() => _isMovingText = false);
  }

  void _resetTextPosition() {
    if (_textShift == Offset.zero) return;
    setState(() => _textShift = Offset.zero);
  }

  Future<Uint8List?> _render() async {
    final key = _boundaryKeys[_index];
    if (key == null) return null;
    // Garantiza que el fondo ya esté decodificado antes de capturar el frame.
    await precacheImage(AssetImage(_backgrounds[_index]), context);
    if (!mounted) return null;
    return VerseImageExporter.capture(key);
  }

  Future<void> _handleShare() async {
    if (_isBusy || _backgrounds.isEmpty) return;
    setState(() {
      _isBusy = true;
      _isMovingText = false;
    });
    try {
      final bytes = await _render();
      if (bytes == null || !mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      await VerseImageExporter.share(
        bytes: bytes,
        reference: widget.reference,
        sharePositionOrigin: box == null || !box.hasSize
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      );
    } catch (error) {
      debugPrint('No se pudo compartir el versículo: $error');
      _notify('No se pudo compartir la imagen. Inténtalo de nuevo.');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _handleDownload() async {
    if (_isBusy || _backgrounds.isEmpty) return;
    setState(() {
      _isBusy = true;
      _isMovingText = false;
    });
    try {
      final bytes = await _render();
      if (bytes == null || !mounted) return;
      final result = await VerseImageExporter.saveToGallery(
        bytes: bytes,
        reference: widget.reference,
      );
      switch (result) {
        case SaveToGalleryResult.saved:
          _notify('Imagen guardada en tu galería, álbum «Biblia».');
        case SaveToGalleryResult.permissionDenied:
          _notify('Necesitas dar permiso de fotos para guardar la imagen.');
        case SaveToGalleryResult.pluginNotAvailable:
          _notify('Reinicia la app por completo para activar la descarga.');
        case SaveToGalleryResult.failed:
          _notify('No se pudo guardar la imagen. Inténtalo de nuevo.');
      }
    } catch (error) {
      debugPrint('No se pudo descargar el versículo: $error');
      _notify('No se pudo guardar la imagen. Inténtalo de nuevo.');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _notify(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primaryContainer,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      appBar: AppBar(
        backgroundColor: _canvas,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Compartir versículo',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.reference,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondaryFixedDim,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.secondaryFixed),
            )
          : _backgrounds.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No hay fondos disponibles en assets/fondos-img/.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            )
          : SafeArea(
              top: false,
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _backgrounds.length,
                      onPageChanged: _onPageChanged,
                      itemBuilder: (context, index) => _buildPage(index),
                    ),
                  ),
                  _buildToolbar(),
                  _buildFontPicker(),
                  _buildThumbnails(),
                  _buildActions(),
                ],
              ),
            ),
    );
  }

  Widget _buildPage(int index) {
    final key = _boundaryKeys.putIfAbsent(index, () => GlobalKey());
    final isCurrent = index == _index;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      child: Center(
        child: AnimatedScale(
          scale: isCurrent ? 1 : 0.94,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: AspectRatio(
            aspectRatio: 4 / 5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                // El RepaintBoundary queda dentro del recorte redondeado para
                // que el PNG exportado salga rectangular y a sangre completa.
                child: RepaintBoundary(
                  key: key,
                  child: MediaQuery.withNoTextScaling(
                    child: VerseBackgroundCard(
                      backgroundAsset: _backgrounds[index],
                      reference: widget.reference,
                      verseText: widget.verseText,
                      font: _font,
                      fontScale: _fontScale,
                      textAlign: _textAlign,
                      textShift: _textShift,
                      // Las guías son solo ayuda en pantalla: al exportar
                      // siempre están apagadas.
                      showGuides: isCurrent && _isMovingText,
                      onDragStart: isCurrent ? _onTextDragStart : null,
                      onDragUpdate: isCurrent ? _onTextDragUpdate : null,
                      onDragEnd: isCurrent ? _onTextDragEnd : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Reducir texto',
            onPressed: _fontScale <= _minFontScale
                ? null
                : () => _changeFontScale(-_fontScaleStep),
            icon: const Icon(Icons.text_decrease, size: 20),
            color: Colors.white,
            disabledColor: Colors.white24,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            tooltip: 'Aumentar texto',
            onPressed: _fontScale >= _maxFontScale
                ? null
                : () => _changeFontScale(_fontScaleStep),
            icon: const Icon(Icons.text_increase, size: 20),
            color: Colors.white,
            disabledColor: Colors.white24,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            tooltip: '${_alignHint.label} · toca para cambiar',
            onPressed: _cycleTextAlign,
            icon: Icon(_alignHint.icon, size: 20),
            color: Colors.white,
            visualDensity: VisualDensity.compact,
          ),
          Expanded(
            child: Text(
              'Fondo ${_index + 1}/${_backgrounds.length} · mantén presionado '
              'el versículo para moverlo',
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 10,
                height: 1.3,
                color: Colors.white54,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Centrar el texto',
            onPressed: _textShift == Offset.zero ? null : _resetTextPosition,
            icon: const Icon(Icons.filter_center_focus, size: 20),
            color: Colors.white,
            disabledColor: Colors.white24,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildFontPicker() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: VerseFont.all.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final font = VerseFont.all[index];
          final isSelected = font.family == _font.family;
          return Center(
            child: GestureDetector(
              onTap: () => _selectFont(font),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.secondaryFixed
                      : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.secondaryFixed
                        : Colors.white24,
                  ),
                ),
                // La etiqueta se dibuja con su propia fuente, igual que en
                // Instagram, para que se vea el estilo antes de elegirlo.
                child: Text(
                  font.label,
                  style: TextStyle(
                    fontFamily: font.family,
                    fontSize: 15 * font.sizeFactor,
                    color: isSelected
                        ? AppColors.onSecondaryFixed
                        : Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThumbnails() {
    return SizedBox(
      height: _thumbSize + 14,
      child: ListView.separated(
        controller: _thumbController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: _thumbPadding),
        itemCount: _backgrounds.length,
        separatorBuilder: (_, _) => const SizedBox(width: _thumbGap),
        itemBuilder: (context, index) {
          final isSelected = index == _index;
          return Center(
            child: GestureDetector(
              onTap: () => _goToBackground(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: _thumbSize,
                height: isSelected ? _thumbSize : _thumbSize - 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.secondaryFixed
                        : Colors.white24,
                    width: isSelected ? 2.5 : 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    _backgrounds[index],
                    fit: BoxFit.cover,
                    cacheWidth: 160,
                    gaplessPlayback: true,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isBusy ? null : _handleDownload,
              icon: const Icon(Icons.download_rounded, size: 20),
              label: const Text('Descargar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white38,
                side: const BorderSide(color: Colors.white38),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: _isBusy ? null : _handleShare,
              icon: _isBusy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.onSecondaryFixed,
                      ),
                    )
                  : const Icon(Icons.share_rounded, size: 20),
              label: Text(_isBusy ? 'Preparando…' : 'Compartir'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondaryFixed,
                foregroundColor: AppColors.onSecondaryFixed,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta 4:5 con el fondo, el velo oscuro y el bloque de texto arrastrable.
class VerseBackgroundCard extends StatelessWidget {
  final String backgroundAsset;
  final String reference;
  final String verseText;
  final VerseFont font;
  final double fontScale;

  /// Alineación del versículo dentro de su caja. Centrado deja la caja pegada
  /// al texto; izquierda y derecha la estiran para que el texto llegue al borde.
  final TextAlign textAlign;

  /// Desplazamiento del bloque de texto como fracción del lado de la tarjeta.
  final Offset textShift;

  final bool showGuides;
  final VoidCallback? onDragStart;
  final ValueChanged<Offset>? onDragUpdate;
  final VoidCallback? onDragEnd;

  const VerseBackgroundCard({
    super.key,
    required this.backgroundAsset,
    required this.reference,
    required this.verseText,
    this.font = const VerseFont(family: 'VerseClassic', label: 'Clásica'),
    this.fontScale = 1,
    this.textAlign = TextAlign.center,
    this.textShift = Offset.zero,
    this.showGuides = false,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final padding = width * 0.085;
        final innerWidth = width - padding * 2;

        final quoteStyle = TextStyle(
          fontFamily: VerseFont.quoteFamily,
          fontSize: width * 0.15,
          height: 1,
          color: AppColors.secondaryFixed.withValues(alpha: 0.85),
        );
        final referenceStyle = TextStyle(
          fontFamily: VerseFont.captionFamily,
          fontSize: width * 0.04,
          letterSpacing: width * 0.005,
          color: AppColors.secondaryFixed,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: width * 0.02,
            ),
          ],
        );

        final gapAfterQuote = width * 0.01;
        final gapBeforeRule = width * 0.055;
        final gapAfterRule = width * 0.042;
        const ruleHeight = 2.0;

        // La comilla y la referencia quedan ancladas a los bordes; el hueco que
        // sobra entre ellas es la franja donde vive el versículo.
        final rawBandTop =
            padding +
            _measureHeight('“', quoteStyle, innerWidth) +
            gapAfterQuote;
        final rawBandBottom =
            padding +
            _measureHeight(
              reference.toUpperCase(),
              referenceStyle,
              innerWidth,
            ) +
            gapAfterRule +
            ruleHeight +
            gapBeforeRule;

        // Si una referencia muy larga se come la tarjeta, se reparte el espacio
        // en vez de dejar la franja con altura negativa.
        final minBandHeight = height * 0.2;
        final overflow = (rawBandTop + rawBandBottom + minBandHeight) - height;
        final shrink = overflow <= 0 ? 0.0 : overflow / 2;
        final bandTop = (rawBandTop - shrink).clamp(0.0, height);
        final bandBottom = (rawBandBottom - shrink).clamp(
          0.0,
          height - bandTop,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              backgroundAsset,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              filterQuality: FilterQuality.medium,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.42),
                    Colors.black.withValues(alpha: 0.22),
                    Colors.black.withValues(alpha: 0.62),
                  ],
                  stops: const [0, 0.42, 1],
                ),
              ),
            ),
            if (showGuides) _buildCenterGuides(width, height),

            // Capa fija: la comilla arriba.
            Positioned(
              left: padding,
              right: padding,
              top: padding,
              child: Text('“', textAlign: TextAlign.center, style: quoteStyle),
            ),

            // Capa fija: el filete y la referencia abajo.
            Positioned(
              left: padding,
              right: padding,
              bottom: padding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: width * 0.14,
                    height: ruleHeight,
                    color: AppColors.secondaryFixed,
                  ),
                  SizedBox(height: gapAfterRule),
                  Text(
                    reference.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: referenceStyle,
                  ),
                ],
              ),
            ),

            // Capa móvil: solo el versículo. Centrado en su franja cuando no se
            // ha movido, y desplazable sobre toda la tarjeta.
            Positioned(
              left: padding,
              right: padding,
              top: bandTop,
              bottom: bandBottom,
              child: Transform.translate(
                offset: Offset(textShift.dx * width, textShift.dy * height),
                // `Center` deja la caja con su tamaño natural, así el área
                // táctil es el versículo y no toda la tarjeta: fuera de ella el
                // dedo sigue sirviendo para pasar de fondo.
                child: Center(child: _buildVerseBox(width, height)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCenterGuides(double width, double height) {
    final showVertical = textShift.dx == 0;
    final showHorizontal = textShift.dy == 0;
    if (!showVertical && !showHorizontal) return const SizedBox.shrink();
    return IgnorePointer(
      child: Stack(
        children: [
          if (showVertical)
            Positioned(
              left: width / 2 - 0.5,
              top: height * 0.08,
              bottom: height * 0.08,
              child: Container(
                width: 1,
                color: AppColors.secondaryFixed.withValues(alpha: 0.65),
              ),
            ),
          if (showHorizontal)
            Positioned(
              top: height / 2 - 0.5,
              left: width * 0.08,
              right: width * 0.08,
              child: Container(
                height: 1,
                color: AppColors.secondaryFixed.withValues(alpha: 0.65),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVerseBox(double width, double height) {
    final boxPadding = width * 0.015;
    final borderRadius = BorderRadius.circular(width * 0.025);

    return LayoutBuilder(
      builder: (context, available) {
        final verseStyle = _fitVerseStyle(
          maxWidth: available.maxWidth - boxPadding * 2 - 2,
          maxHeight: available.maxHeight - boxPadding * 2 - 2,
          cardWidth: width,
        );

        final box = SizedBox(
          width: textAlign == TextAlign.center ? null : available.maxWidth,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: showGuides
                  ? Colors.black.withValues(alpha: 0.18)
                  : Colors.transparent,
              border: Border.all(
                color: showGuides
                    ? Colors.white.withValues(alpha: 0.55)
                    : Colors.transparent,
              ),
              borderRadius: borderRadius,
            ),
            child: Padding(
              padding: EdgeInsets.all(boxPadding),
              child: Text(verseText, textAlign: textAlign, style: verseStyle),
            ),
          ),
        );

        if (onDragUpdate == null) return box;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPressStart: (_) => onDragStart?.call(),
          onLongPressMoveUpdate: (details) {
            onDragUpdate?.call(
              Offset(
                details.offsetFromOrigin.dx / width,
                details.offsetFromOrigin.dy / height,
              ),
            );
          },
          onLongPressEnd: (_) => onDragEnd?.call(),
          onLongPressCancel: () => onDragEnd?.call(),
          child: box,
        );
      },
    );
  }

  TextStyle _fitVerseStyle({
    required double maxWidth,
    required double maxHeight,
    required double cardWidth,
  }) {
    final blurRadius = cardWidth * 0.03;
    final maxFontSize = cardWidth * 0.082 * font.sizeFactor * fontScale;
    final minFontSize = cardWidth * 0.018;

    TextStyle styleFor(double size) =>
        font.verseStyle(fontSize: size, blurRadius: blurRadius);

    if (maxWidth <= 0 || maxHeight <= 0 || maxFontSize <= minFontSize) {
      return styleFor(minFontSize);
    }
    double verseHeight(double size) => _measureHeight(
      verseText,
      styleFor(size),
      maxWidth,
      textAlign: textAlign,
    );

    if (verseHeight(maxFontSize) <= maxHeight) {
      return styleFor(maxFontSize);
    }

    var low = minFontSize;
    var high = maxFontSize;
    for (var iteration = 0; iteration < 12; iteration++) {
      final middle = (low + high) / 2;
      if (verseHeight(middle) <= maxHeight) {
        low = middle;
      } else {
        high = middle;
      }
    }
    return styleFor(low);
  }

  static double _measureHeight(
    String text,
    TextStyle style,
    double maxWidth, {
    TextAlign textAlign = TextAlign.center,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: textAlign,
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.noScaling,
    )..layout(maxWidth: maxWidth);
    final height = painter.height;
    painter.dispose();
    return height;
  }
}
