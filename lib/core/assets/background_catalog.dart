import 'package:flutter/services.dart';

/// Lista los fondos disponibles en `assets/fondos-img/`.
///
/// Se leen desde el manifiesto de assets, así que al agregar una imagen nueva
/// a la carpeta aparece sola en el compositor (solo hace falta reconstruir).
class BackgroundCatalog {
  BackgroundCatalog._();

  static const String folder = 'assets/fondos-img/';

  static const Set<String> _imageExtensions = {
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
  };

  /// Respaldo por si el manifiesto no se puede leer.
  static const List<String> _fallback = [
    '${folder}fondo-1.jpeg',
    '${folder}fondo-2.jpeg',
    '${folder}fondo-3.jpeg',
  ];

  static List<String>? _cache;

  static Future<List<String>> load() async {
    final cached = _cache;
    if (cached != null) return cached;

    List<String> paths;
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      paths =
          manifest
              .listAssets()
              .where((asset) => asset.startsWith(folder) && _isImage(asset))
              .toList()
            ..sort(_compareNatural);
    } catch (_) {
      paths = const [];
    }

    _cache = paths.isEmpty ? _fallback : paths;
    return _cache!;
  }

  static bool _isImage(String asset) {
    final dotIndex = asset.lastIndexOf('.');
    if (dotIndex < 0) return false;
    return _imageExtensions.contains(asset.substring(dotIndex).toLowerCase());
  }

  /// Orden natural para que `fondo-2` quede antes de `fondo-10`.
  static int _compareNatural(String a, String b) {
    final chunksA = _chunks(a);
    final chunksB = _chunks(b);
    final length = chunksA.length < chunksB.length
        ? chunksA.length
        : chunksB.length;

    for (var i = 0; i < length; i++) {
      final chunkA = chunksA[i];
      final chunkB = chunksB[i];
      final numberA = int.tryParse(chunkA);
      final numberB = int.tryParse(chunkB);
      final comparison = (numberA != null && numberB != null)
          ? numberA.compareTo(numberB)
          : chunkA.toLowerCase().compareTo(chunkB.toLowerCase());
      if (comparison != 0) return comparison;
    }
    return chunksA.length.compareTo(chunksB.length);
  }

  static List<String> _chunks(String value) =>
      RegExp(r'\d+|\D+').allMatches(value).map((m) => m.group(0)!).toList();
}
