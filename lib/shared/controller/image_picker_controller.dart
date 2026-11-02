import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_app_template/core/utils/helpers/misc/recent_image_store.dart';

class ImagePickerController extends ChangeNotifier {
  static const int maxRecentImages = 10;
  static const String mainBuilderId = 'image_picker_main';
  static const String recentBuilderId = 'image_picker_recent';

  final ImagePicker _picker = ImagePicker();
  final RecentImageStore _recentStore = RecentImageStore();

  /// The currently picked image file.
  File? pickedImage;

  /// Recently selected images.
  final List<File> recentImages = [];

  /// Returns true if an image is selected.
  bool get hasImage => pickedImage != null;

  ImagePickerController() {
    _loadRecentImages();
  }

  /// Picks an image from the gallery.
  Future<void> pickFromGallery() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 40,
    );

    if (file == null) return;

    pickedImage = File(file.path);

    await _addToRecentImages(pickedImage!);

    notifyListeners();
  }

  /// Picks an image using the camera.
  Future<void> pickFromCamera() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 40,
    );

    if (file == null) return;

    pickedImage = File(file.path);

    await _addToRecentImages(pickedImage!);

    notifyListeners();
  }

  /// Picks an image file using file picker.
  Future<void> pickFromFile() async {
    final FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.image,
      compressionQuality: 40,
    );

    if (result == null) return;

    final String? path = result.files.single.path;

    if (path == null) return;

    pickedImage = File(path);

    await _addToRecentImages(pickedImage!);

    notifyListeners();
  }

  /// Selects image from recent images list.
  Future<void> selectRecentImage(File image) async {
    pickedImage = image;

    await _addToRecentImages(image);

    notifyListeners();
  }

  /// Removes the currently selected image.
  void removeImage() {
    pickedImage = null;

    notifyListeners();
  }

  Future<void> removeRecentImage(File image) async {
    recentImages.removeWhere((e) => e.path == image.path);

    if (pickedImage?.path == image.path) {
      pickedImage = null;
    }

    await _recentStore.delete(image);
    await _recentStore.persist(recentImages);

    notifyListeners();
  }

  Future<void> clearRecentImages() async {
    recentImages.clear();
    pickedImage = null;

    await _recentStore.clear();
    await _recentStore.persist(recentImages);

    notifyListeners();
  }

  /// Adds image to recent images list.
  Future<void> _addToRecentImages(File image) async {
    final storedImage = await _recentStore.ensureStored(image);

    recentImages.removeWhere((e) => e.path == storedImage.path);

    recentImages.insert(0, storedImage);

    if (recentImages.length > maxRecentImages) {
      final removed = recentImages.sublist(maxRecentImages);
      recentImages.removeRange(maxRecentImages, recentImages.length);
      await _recentStore.deleteAll(removed);
    }

    await _recentStore.persist(recentImages);
  }

  Future<void> _loadRecentImages() async {
    final images = await _recentStore.load();
    recentImages
      ..clear()
      ..addAll(images);
    notifyListeners();
  }
}
