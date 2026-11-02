import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_app_template/core/utils/extensions/context_extension.dart';
import 'package:flutter_app_template/core/utils/extensions/responsive_size.dart';
import 'package:flutter_app_template/core/utils/extensions/responsive_values.dart';
import 'package:flutter_app_template/shared/widgets/cards/my_card.dart';
import 'package:flutter_app_template/shared/widgets/misc/my_progress_indicator.dart';

class MyProgressDialog extends StatelessWidget {
  final String? message;

  const MyProgressDialog({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Material(
          color: Colors.transparent,
          child: MyCard.elevated(
            constraints: BoxConstraints(
              minWidth: context.setSize(120),
              maxWidth: context.setSize(240),
              minHeight: context.setSize(120),
            ),
            padding: context.insetsAllL,
            color: context.colorScheme.surface,
            borderRadius: context.brL,
            elevation: context.elevationL,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                MyProgressIndicator(
                  size: context.setSize(38),
                  strokeWidth: context.setSize(4),
                ),
                if (message != null) ...[
                  SizedBox(height: context.spaceL),
                  Text(
                    message!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: context.setSize(12),
                      fontWeight: FontWeight.w600,
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
