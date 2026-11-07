import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:halati/core/utils/extensions/context_extension.dart';
import 'package:halati/core/utils/extensions/responsive_size.dart';

class SliverFilterDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;
  final Color? backgroundColor;
  final bool withBlur;

  const SliverFilterDelegate({
    required this.height,
    required this.child,
    this.backgroundColor,
    this.withBlur = true,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final bgColor = (backgroundColor ?? context.colorScheme.surface).withValues(
      alpha: withBlur ? 0.8 : 1.0,
    );

    Widget content = SizedBox(height: height, child: child);

    if (withBlur) {
      content = ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              border: overlapsContent
                  ? Border(
                      bottom: BorderSide(
                        color: context.colorScheme.outlineVariant.withValues(
                          alpha: 0.35,
                        ),
                        width: context.setSize(0.5),
                      ),
                    )
                  : null,
            ),
            child: content,
          ),
        ),
      );
    } else {
      content = Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: overlapsContent
              ? Border(
                  bottom: BorderSide(
                    color: context.colorScheme.outlineVariant.withValues(
                      alpha: 0.35,
                    ),
                    width: context.setSize(0.5),
                  ),
                )
              : null,
        ),
        child: content,
      );
    }

    return content;
  }

  @override
  bool shouldRebuild(covariant SliverFilterDelegate oldDelegate) {
    return oldDelegate.height != height ||
        oldDelegate.child != child ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.withBlur != withBlur;
  }
}
