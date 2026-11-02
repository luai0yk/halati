import 'dart:io';
import 'package:share_plus/share_plus.dart';

class ShareHelper {
  ShareHelper._();

  /// Shares a single file.
  static Future<void> shareFile(
    File file, {
    String? text,
    String? subject,
  }) async {
    if (await file.exists()) {
      final xFile = XFile(file.path);
      await SharePlus.instance.share(
        ShareParams(files: [xFile], text: text, subject: subject),
      );
    }
  }

  /// Shares multiple files.
  static Future<void> shareFiles(
    List<File> files, {
    String? text,
    String? subject,
  }) async {
    final xFiles = <XFile>[];
    for (var file in files) {
      if (await file.exists()) {
        xFiles.add(XFile(file.path));
      }
    }

    if (xFiles.isNotEmpty) {
      await SharePlus.instance.share(
        ShareParams(files: xFiles, text: text, subject: subject),
      );
    }
  }

  /// Shares a text string.
  static Future<void> shareText(String text, {String? subject}) async {
    await SharePlus.instance.share(ShareParams(text: text, subject: subject));
  }
}
