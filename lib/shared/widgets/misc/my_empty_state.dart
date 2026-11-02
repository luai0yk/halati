import 'package:flutter/material.dart';
import 'package:flutter_app_template/core/utils/extensions/context_extension.dart';
import 'package:flutter_app_template/core/utils/extensions/responsive_size.dart';
import 'package:flutter_app_template/core/utils/extensions/responsive_values.dart';
import 'package:flutter_app_template/shared/widgets/buttons/my_button.dart';
import 'package:flutter_app_template/shared/widgets/misc/my_icon.dart';

enum MyEmptyStateSize { normal, small }

class MyEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;
  final MyEmptyStateSize size;

  const MyEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
    this.size = MyEmptyStateSize.normal,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSmall = size == MyEmptyStateSize.small;

    final double horizontalPadding = context.setSize(isSmall ? 16 : 20);

    final double verticalPadding = context.setSize(isSmall ? 16 : 20);

    final double iconContainerSize = context.setSize(isSmall ? 56 : 76);

    final double iconSize = context.setSize(isSmall ? 26 : 40);

    final double iconPadding = context.setSize(isSmall ? 12 : 16);

    final double titleSize = context.setSize(isSmall ? 14 : 16);

    final double subtitleSize = context.setSize(isSmall ? 11 : 12);

    final double iconSpacing = context.setSize(isSmall ? 10 : 14);

    final double textSpacing = context.setSize(isSmall ? 4 : 6);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconContainerSize,
            height: iconContainerSize,
            padding: EdgeInsets.all(iconPadding),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: MyIcon(
              icon: icon,
              size: iconSize,
              color: context.colorScheme.primary,
            ),
          ),

          SizedBox(height: iconSpacing),

          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleMedium?.copyWith(
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: context.colorScheme.onSurface,
            ),
          ),

          SizedBox(height: textSpacing),

          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.setSize(340)),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                fontSize: subtitleSize,
                height: 1.4,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          if (actionText != null && onAction != null) ...[
            context.verticalSpace(
              isSmall ? context.setSize(3) : context.setSize(6),
            ),
            MyButton.text(
              text: actionText!,
              height: isSmall ? context.setSize(30) : context.setSize(36),
              fontSize: context.setSize(isSmall ? 13 : 15),
              borderRadius: context.brS,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}
