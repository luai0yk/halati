import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:halati/core/constants/app_icons.dart';
import 'package:halati/core/utils/extensions/context_extension.dart';
import 'package:halati/core/utils/extensions/responsive_size.dart';
import 'package:halati/core/utils/extensions/responsive_values.dart';
import 'package:halati/shared/widgets/cards/my_card.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:halati/shared/widgets/images/image_viewer_page.dart';
import 'package:halati/shared/widgets/misc/my_icon.dart';
import 'package:halati/shared/widgets/misc/my_progress_indicator.dart';

class MyImage extends StatefulWidget {
  /// The asset image path.
  final String? assetImage;

  /// The image file.
  final File? fileImage;

  /// The image url.
  final String? networkImage;

  /// Optional image tint color.
  final Color? color;

  /// Border radius.
  final BorderRadius? borderRadius;

  /// Image width.
  final double? width;

  /// Image height.
  final double? height;

  /// Image fit.
  final BoxFit fit;

  /// Optional border color.
  final Color? borderColor;

  /// Optional border width.
  final double? borderWidth;

  /// Optional padding around the image.
  final EdgeInsets? padding;

  /// Optional background color.
  final Color? backgroundColor;

  /// Whether to show a skeleton loading state for network images.
  final bool showSkeleton;

  /// Whether the image can be opened in full screen.
  final bool isViewable;

  /// Optional custom error widget to show when loading fails.
  final Widget? errorWidget;

  /// Optional custom error builder.
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  /// Optional target width for decoded image caching.
  final int? cacheWidth;

  /// Optional target height for decoded image caching.
  final int? cacheHeight;

  const MyImage.asset({
    super.key,
    required String asset,
    this.borderRadius,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.color,
    this.borderColor,
    this.borderWidth,
    this.padding,
    this.backgroundColor,
    this.errorWidget,
    this.errorBuilder,
    this.cacheWidth,
    this.cacheHeight,
  }) : assetImage = asset,
       fileImage = null,
       networkImage = null,
       showSkeleton = false,
       isViewable = false;

  const MyImage.file({
    super.key,
    required File file,
    this.borderRadius,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.color,
    this.borderColor,
    this.borderWidth,
    this.padding,
    this.backgroundColor,
    this.errorWidget,
    this.errorBuilder,
    this.cacheWidth,
    this.cacheHeight,
    this.isViewable = false,
  }) : fileImage = file,
       assetImage = null,
       networkImage = null,
       showSkeleton = false;

  const MyImage.network({
    super.key,
    required String url,
    this.borderRadius,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.color,
    this.borderColor,
    this.borderWidth,
    this.padding,
    this.backgroundColor,
    this.errorWidget,
    this.errorBuilder,
    this.cacheWidth,
    this.cacheHeight,
    this.showSkeleton = true,
    this.isViewable = false,
  }) : networkImage = url,
       assetImage = null,
       fileImage = null;

  @override
  State<MyImage> createState() => _MyImageState();
}

class _MyImageState extends State<MyImage> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    Widget content = widget.assetImage != null
        ? _buildAssetImage()
        : widget.fileImage != null
        ? _buildFileImage()
        : _buildNetworkImage(context);

    final resolvedRadius = widget.borderRadius ?? context.brM;

    // If padding is applied, the inner child sits inside the outer clip
    // and remains a sharp rectangle unless we clip it too.
    if (widget.padding != null && widget.padding != EdgeInsets.zero) {
      final innerRadius = BorderRadius.only(
        topLeft: resolvedRadius.topLeft / 1.5,
        topRight: resolvedRadius.topRight / 1.5,
        bottomLeft: resolvedRadius.bottomLeft / 1.5,
        bottomRight: resolvedRadius.bottomRight / 1.5,
      );

      content = ClipRRect(borderRadius: innerRadius, child: content);
    }

    // Using MyCard to handle borders, clipping, and background gracefully.
    final card = MyCard.filled(
      width: widget.width,
      height: widget.height,
      padding: widget.padding ?? EdgeInsets.zero,
      borderRadius: resolvedRadius,
      color: widget.backgroundColor ?? Colors.transparent,
      borderColor: widget.borderColor,
      borderWidth: widget.borderWidth,
      child: content,
    );

    if (widget.isViewable &&
        (widget.fileImage != null || widget.networkImage != null)) {
      final String imagePath = widget.networkImage ?? widget.fileImage!.path;
      return GestureDetector(
        onTap: _hasError
            ? null
            : () {
                ImageViewerPage.show(context, image: imagePath);
              },
        child: Hero(tag: imagePath, child: card),
      );
    }

    return card;
  }

  bool get _isAssetSvg {
    final path = widget.assetImage?.toLowerCase() ?? '';
    return path.endsWith('.svg');
  }

  Widget _buildAssetImage() {
    if (_isAssetSvg) {
      return SvgPicture.asset(
        widget.assetImage!,
        width: double.infinity,
        height: double.infinity,
        fit: widget.fit,
        colorFilter: widget.color != null
            ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
            : null,
      );
    }
    return Image.asset(
      widget.assetImage!,
      width: double.infinity,
      height: double.infinity,
      fit: widget.fit,
      color: widget.color,
      cacheWidth: widget.cacheWidth,
      cacheHeight: widget.cacheHeight,
      errorBuilder: _localErrorBuilder,
    );
  }

  Widget _buildFileImage() {
    return Image.file(
      widget.fileImage!,
      width: double.infinity,
      height: double.infinity,
      fit: widget.fit,
      color: widget.color,
      cacheWidth: widget.cacheWidth,
      cacheHeight: widget.cacheHeight,
      errorBuilder: _localErrorBuilder,
    );
  }

  bool get _isSvg {
    final url = widget.networkImage?.toLowerCase() ?? '';
    return url.endsWith('.svg') ||
        url.contains('.svg?') ||
        url.contains('image/svg+xml');
  }

  Widget _buildNetworkImage(BuildContext context) {
    if (widget.networkImage == null || widget.networkImage!.isEmpty) {
      return _localErrorBuilder(context, '', null);
    }

    if (_isSvg) {
      return SvgPicture.network(
        widget.networkImage!,
        width: double.infinity,
        height: double.infinity,
        fit: widget.fit,
        colorFilter: widget.color != null
            ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
            : null,
        placeholderBuilder: (context) => _loadingBuilder(context),
      );
    }

    return CachedNetworkImage(
      imageUrl: widget.networkImage!,
      width: double.infinity,
      height: double.infinity,
      fit: widget.fit,
      color: widget.color,
      memCacheWidth: widget.cacheWidth,
      memCacheHeight: widget.cacheHeight,
      errorWidget: (context, url, error) {
        debugPrint('MyImage Network Error: $error for URL: $url');
        if (!_hasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _hasError = true;
              });
            }
          });
        }
        return _networkErrorBuilder(context);
      },
      progressIndicatorBuilder: (context, url, progress) {
        if (widget.showSkeleton) {
          return _loadingBuilder(context);
        }
        return Center(child: MyProgressIndicator(value: progress.progress));
      },
    );
  }

  Widget _localErrorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    if (!_hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      });
    }
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(context, error, stackTrace);
    }
    return _buildErrorIcon(context);
  }

  Widget _networkErrorBuilder(BuildContext context) {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }
    return _buildErrorIcon(context);
  }

  Widget _buildErrorIcon(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double iconSize = context.setSize(35);
        if (constraints.maxWidth != double.infinity &&
            constraints.maxHeight != double.infinity) {
          final minSize = constraints.maxWidth < constraints.maxHeight
              ? constraints.maxWidth
              : constraints.maxHeight;
          if (minSize > 0) {
            iconSize = (minSize * 0.4).clamp(16.0, context.setSize(35));
          }
        }
        return Container(
          color: context.colorScheme.surfaceContainer,
          alignment: Alignment.center,
          child: MyIcon(
            icon: AppIcons.imageNotSupported,
            size: iconSize,
            color: context.colorScheme.onSurfaceVariant,
          ),
        );
      },
    );
  }

  Widget _loadingBuilder(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Container(
        color: context.colorScheme.surface,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
