import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Resultado de guardar la imagen en la galería.
enum SaveToGalleryResult { saved, permissionDenied, pluginNotAvailable, failed }

/// Convierte la tarjeta del compositor (un [RepaintBoundary]) en un PNG y lo
/// comparte o lo guarda en la galería.
class VerseImageExporter {
  VerseImageExporter._();

  /// Ancho objetivo del PNG exportado, en píxeles.
  static const double exportWidth = 1080;

  static const String _albumName = 'Biblia';

  /// Captura el contenido del [RepaintBoundary] identificado por [boundaryKey].
  ///
  /// Reintenta mientras el render object todavía necesite pintarse, porque
  /// `toImage()` devuelve un frame vacío si se llama demasiado pronto.
  static Future<Uint8List> capture(GlobalKey boundaryKey) async {
    await WidgetsBinding.instance.endOfFrame;

    RenderRepaintBoundary? boundary;
    for (var attempt = 0; attempt < 15; attempt++) {
      boundary =
          boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary != null && !_needsPaint(boundary)) break;
      await Future<void>.delayed(const Duration(milliseconds: 40));
    }

    if (boundary == null) {
      throw StateError('No se encontró la tarjeta para exportar.');
    }

    final logicalWidth = boundary.size.width;
    final pixelRatio = logicalWidth <= 0
        ? 3.0
        : (exportWidth / logicalWidth).clamp(1.0, 4.0);

    final image = await boundary.toImage(pixelRatio: pixelRatio);
    try {
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw StateError('No se pudo codificar la imagen del versículo.');
      }
      return byteData.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }

  /// `debugNeedsPaint` solo está disponible en debug; en release lanza error,
  /// por eso se consulta dentro de un `assert`.
  static bool _needsPaint(RenderRepaintBoundary boundary) {
    var needsPaint = false;
    assert(() {
      needsPaint = boundary.debugNeedsPaint;
      return true;
    }());
    return needsPaint;
  }

  /// Abre la hoja nativa de compartir (WhatsApp, Facebook, Instagram, correo…).
  ///
  /// Se envía únicamente la imagen: sin `text` ni `subject`, para que las redes
  /// no agreguen el versículo como texto junto a la foto.
  static Future<void> share({
    required Uint8List bytes,
    required String reference,
    Rect? sharePositionOrigin,
  }) async {
    final file = await _writeTempFile(bytes, reference);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  /// Guarda el PNG en la galería del dispositivo, dentro del álbum `Biblia`.
  static Future<SaveToGalleryResult> saveToGallery({
    required Uint8List bytes,
    required String reference,
  }) async {
    try {
      if (!await Gal.hasAccess(toAlbum: true)) {
        if (!await Gal.requestAccess(toAlbum: true)) {
          return SaveToGalleryResult.permissionDenied;
        }
      }
      await Gal.putImageBytes(
        bytes,
        album: _albumName,
        name: _fileStem(reference),
      );
      return SaveToGalleryResult.saved;
    } on GalException catch (error) {
      debugPrint('No se pudo guardar en la galería: ${error.type}');
      return error.type == GalExceptionType.accessDenied
          ? SaveToGalleryResult.permissionDenied
          : SaveToGalleryResult.failed;
    } on MissingPluginException catch (_) {
      // El plugin nativo se registra al recompilar la app, no con hot restart.
      return SaveToGalleryResult.pluginNotAvailable;
    } catch (error) {
      debugPrint('No se pudo guardar en la galería: $error');
      return SaveToGalleryResult.failed;
    }
  }

  static Future<File> _writeTempFile(Uint8List bytes, String reference) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${_fileStem(reference)}.png');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static String _fileStem(String reference) {
    final slug = reference
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    final stamp = DateTime.now().millisecondsSinceEpoch;
    return 'biblia-${slug.isEmpty ? 'versiculo' : slug}-$stamp';
  }
}
