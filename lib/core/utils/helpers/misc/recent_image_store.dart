import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class RecentImageStore {
  static const String _dirName = 'recent_images';
  static const String _indexFileName = 'recent_images.json';

  Future<List<File>> load() async {
    final Directory dir = await _imagesDir();
    final File indexFile = await _indexFile();

    if (!await indexFile.exists()) {
      return [];
    }

    final String raw = await indexFile.readAsString();
    final List<dynamic> names = jsonDecode(raw) as List<dynamic>;
    final List<File> files = [];

    for (final name in names) {
      if (name is! String || name.isEmpty) continue;
      final File file = File('${dir.path}/$name');
      if (await file.exists()) {
        files.add(file);
      }
    }

    if (files.length != names.length) {
      await persist(files);
    }

    return files;
  }

  Future<File> ensureStored(File source) async {
    final Directory dir = await _imagesDir();

    if (source.path.startsWith(dir.path)) {
      return source;
    }

    final String extension = _fileExtension(source.path);
    final String fileName =
        '${DateTime.now().millisecondsSinceEpoch}'
        '${extension.isEmpty ? '' : '.$extension'}';
    final File destination = File('${dir.path}/$fileName');

    return source.copy(destination.path);
  }

  Future<void> persist(List<File> files) async {
    final Directory dir = await _imagesDir();
    final File indexFile = await _indexFile();

    final List<String> names = files
        .where((file) => file.path.startsWith(dir.path))
        .map((file) => file.path.substring(dir.path.length + 1))
        .toList();

    await indexFile.writeAsString(jsonEncode(names));
  }

  Future<void> deleteAll(List<File> files) async {
    for (final file in files) {
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  Future<void> delete(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> clear() async {
    final Directory dir = await _imagesDir();

    if (await dir.exists()) {
      await for (final entity in dir.list()) {
        await entity.delete(recursive: true);
      }
    }
  }

  String _fileExtension(String path) {
    final int dotIndex = path.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex == path.length - 1) {
      return '';
    }

    return path.substring(dotIndex + 1);
  }

  Future<Directory> _imagesDir() async {
    final Directory baseDir = await getApplicationDocumentsDirectory();
    final Directory dir = Directory('${baseDir.path}/$_dirName');

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return dir;
  }

  Future<File> _indexFile() async {
    final Directory dir = await _imagesDir();
    return File('${dir.path}/$_indexFileName');
  }
}
