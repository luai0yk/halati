import 'dart:io';

import 'package:flutter/material.dart';
import 'package:halati/core/utils/extensions/context_extension.dart';
import 'package:halati/core/utils/extensions/responsive_size.dart';
import 'package:halati/core/utils/extensions/responsive_values.dart';
import 'package:halati/shared/widgets/cards/my_card.dart';
import 'package:halati/shared/widgets/images/my_image.dart';
import 'package:halati/shared/widgets/misc/my_icon.dart';

class MyAvatar extends StatelessWidget {
  final String? name;
  final String? imagePath;
  final IconData? icon;
  final double? size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? borderWidth;

  const MyAvatar({
    super.key,
    this.name,
    this.imagePath,
    this.icon,
    this.size,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? 40;
    Widget? imageProvider;
    if (imagePath != null && imagePath!.isNotEmpty) {
      imageProvider = ClipOval(
        child: MyImage.file(
          file: File(imagePath!),
          width: context.setSize(size),
          height: context.setSize(size),
        ),
      );
    }

    Widget fallbackContent;
    if (icon != null) {
      fallbackContent = Center(
        child: MyIcon(
          icon: icon!,
          color: foregroundColor ?? context.colorScheme.primary,
          size: context.setSize(size / 2),
        ),
      );
    } else {
      final initial = (name != null && name!.isNotEmpty)
          ? name![0].toUpperCase()
          : '?';
      final isArabic = RegExp(
        r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]',
      ).hasMatch(initial);

      final textWidget = Text(
        initial,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        style: context.textTheme.headlineSmall?.copyWith(
          color: foregroundColor ?? context.colorScheme.primary,
          fontSize: context.setSize(size / 3),
          height: 1,
          leadingDistribution: TextLeadingDistribution.even,
        ),
      );

      fallbackContent = Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: EdgeInsets.all(context.setSize(size / 6)),
            child: isArabic
                ? Transform.translate(
                    offset: Offset(0, -context.setSize(size * 0.06)),
                    child: textWidget,
                  )
                : textWidget,
          ),
        ),
      );
    }

    return MyCard.filled(
      width: context.setSize(size),
      height: context.setSize(size),
      padding: EdgeInsets.zero,
      borderRadius: context.brCircular,
      color:
          backgroundColor ?? context.colorScheme.primary.withValues(alpha: 0.1),
      borderColor: imageProvider != null ? borderColor : null,
      borderWidth: imageProvider != null ? borderWidth : null,
      child: imageProvider ?? fallbackContent,
    );
  }
}
