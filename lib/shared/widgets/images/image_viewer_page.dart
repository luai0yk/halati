import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:status_saver/core/constants/app_durations.dart';
import 'package:status_saver/core/constants/app_icons.dart';
import 'package:status_saver/core/utils/extensions/context_extension.dart';
import 'package:status_saver/core/utils/extensions/responsive_size.dart';
import 'package:status_saver/shared/widgets/appbars/my_app_bar.dart';
import 'package:status_saver/shared/widgets/buttons/my_icon_button.dart';
import 'package:status_saver/shared/widgets/misc/my_icon.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewerPage extends StatefulWidget {
  const ImageViewerPage({
    super.key,
    required this.image,
    this.title,
    this.onSave,
  });

  final String image;
  final String? title;
  final VoidCallback? onSave;

  static void show(
    BuildContext context, {
    required String image,
    String? title,
    VoidCallback? onSave,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        transitionDuration: AppDurations.medium,
        pageBuilder: (context, animation, secondaryAnimation) {
          return ImageViewerPage(
            image: image,
            title: title,
            onSave: onSave,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    // Restore your app's normal system UI configuration here
    // if your main application uses something different.
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    super.dispose();
  }

  ImageProvider get _imageProvider {
    final image = widget.image;

    if (image.startsWith('http://') || image.startsWith('https://')) {
      return CachedNetworkImageProvider(image);
    }

    return FileImage(File(image));
  }

  Widget _errorBuilder(BuildContext context) {
    return Center(
      child: MyIcon(
        icon: AppIcons.imageNotSupported,
        size: context.setSize(35),
        color: context.colorScheme.onSurfaceVariant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // We wrap the Scaffold with its own AnnotatedRegion so that this page overrides
      // the global fallback style set in main.dart, providing a transparent system UI.
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        extendBody: true,
        resizeToAvoidBottomInset: false,
        appBar: MyAppBar(
          color: Colors.transparent,
          isElevated: false,
          isTitleCenter: false,
          title: widget.title ?? '',
          titleColor: Colors.white,
          leadingIconColor: Colors.white,
          leadingBackgroundColor: Colors.white.withValues(alpha: 0.1),
          systemOverlayStyle: overlayStyle,
          actions: [
            if (widget.onSave != null)
              MyIconButton.ghost(
                icon: AppIcons.download,
                iconColor: Colors.white,
                onPressed: widget.onSave,
              ),
          ],
        ),
        body: SizedBox.expand(
          child: Hero(
            tag: widget.image,
            child: PhotoView(
              imageProvider: _imageProvider,
              backgroundDecoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 3,
              errorBuilder: (context, error, stackTrace) {
                return _errorBuilder(context);
              },
            ),
          ),
        ),
      ),
    );
  }
}
