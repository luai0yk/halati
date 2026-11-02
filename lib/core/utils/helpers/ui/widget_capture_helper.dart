 import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

/// Helper utility for capturing Flutter widgets (via [RenderRepaintBoundary]) as images.
class WidgetCaptureHelper {
  WidgetCaptureHelper._();

  /// Captures the widget attached to [boundaryKey] as a PNG [File].
  ///
  /// Returns `null` if the boundary context is not available or if image rasterization fails.
  /// [pixelRatio] defaults to 3.0 for crisp rendering.
  /// [filePrefix] can be provided to customize the generated file name.
  static Future<File?> captureToFile({
    required GlobalKey boundaryKey,
    double pixelRatio = 3.0,
    String filePrefix = 'capture',
  }) async {
    try {
      final boundary =
          boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) return null;

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      Directory tempDir;
      try {
        tempDir = await getTemporaryDirectory();
      } catch (_) {
        tempDir = Directory.systemTemp;
      }

      final file = File(
        '${tempDir.path}/${filePrefix}_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(pngBytes, flush: true);
      return file;
    } catch (_) {
      return null;
    }
  }

  /// Captures the widget attached to [boundaryKey] as raw PNG bytes.
  static Future<Uint8List?> captureToBytes({
    required GlobalKey boundaryKey,
    double pixelRatio = 3.0,
  }) async {
    try {
      final boundary =
          boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) return null;

      return byteData.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }
}
