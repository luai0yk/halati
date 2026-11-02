import 'package:flutter/material.dart';
import 'package:flutter_app_template/core/constants/app_icons.dart';
import 'package:flutter_app_template/core/utils/extensions/context_extension.dart';
import 'package:flutter_app_template/core/utils/extensions/responsive_size.dart';
import 'package:flutter_app_template/core/utils/extensions/responsive_values.dart';
import 'package:flutter_app_template/shared/widgets/misc/my_icon.dart';

enum SnackBarStatus { standard, success, warning, danger, info }

class MySnackBar extends SnackBar {
  MySnackBar({
    super.key,
    required String message,
    required BuildContext context,
    super.duration = const Duration(seconds: 3),
    SnackBarStatus status = SnackBarStatus.standard,
    IconData? icon,
    String? actionText,
    VoidCallback? onAction,
  }) : super(
         elevation: 0,
         backgroundColor: Colors.transparent,
         behavior: SnackBarBehavior.floating,
         padding: EdgeInsets.zero,
         margin: EdgeInsets.all(context.spaceM),
         content: _buildContent(
           context,
           message,
           status,
           icon,
           actionText,
           onAction,
         ),
       );

  static Widget _buildContent(
    BuildContext context,
    String message,
    SnackBarStatus status,
    IconData? icon,
    String? actionText,
    VoidCallback? onAction,
  ) {
    Color bgColor;
    IconData? defaultIcon;

    switch (status) {
      case SnackBarStatus.success:
        bgColor = context.colorScheme.primary;
        defaultIcon = AppIcons.checkCircle;
        break;
      case SnackBarStatus.warning:
        bgColor = Colors.orange;
        defaultIcon = AppIcons.warning;
        break;
      case SnackBarStatus.danger:
        bgColor = context.extendedColors.danger.color;
        defaultIcon = AppIcons.error;
        break;
      case SnackBarStatus.info:
        bgColor = context.extendedColors.info.color;
        defaultIcon = AppIcons.info;
        break;
      case SnackBarStatus.standard:
        bgColor = const Color(0xFF323232);
        defaultIcon = null;
        break;
    }

    final displayIcon = icon ?? defaultIcon;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.setSize(16),
        vertical: context.setSize(12),
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: context.brM,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: context.radiusS,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (displayIcon != null) ...[
            MyIcon(
              icon: displayIcon,
              color: Colors.white,
              size: context.setSize(20),
            ),
            SizedBox(width: context.setSize(12)),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.setSize(14),
                height: 1.3,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          if (actionText != null && onAction != null) ...[
            SizedBox(width: context.setSize(12)),
            Material(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: context.brCircular,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  onAction();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.setSize(12),
                    vertical: context.setSize(6),
                  ),
                  child: Text(
                    actionText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.setSize(13),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
