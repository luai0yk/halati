import 'package:flutter/material.dart';
import 'package:flutter_app_template/core/utils/extensions/context_extension.dart';
import 'package:flutter_app_template/core/utils/extensions/responsive_size.dart';
import 'package:flutter_app_template/core/utils/extensions/responsive_values.dart';

/// A texts to separate widgets from each other vertically
/// Beneficial to separate texts field in forms
class TextSeparator extends StatelessWidget {
  /// Text of the separator
  final String text;

  /// the size of separator texts
  /// Default to size [context.size16]
  final double? fontSize;

  /// Custom color for the text
  final Color? textColor;

  /// To set the top padding
  /// Default to [AppSpacing.gap16]
  final double? top;

  /// To set the top padding
  /// Default to [AppSpacing.gap6]
  final double? bottom;

  /// To set action texts
  /// Default to [context.loc.view_all]
  final String? actionText;

  final Function()? onActionPressed;

  const TextSeparator({
    super.key,
    required this.text,
    this.fontSize,
    this.textColor,
    this.top,
    this.bottom,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colors = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: top ?? context.spaceL,
            bottom: bottom ?? context.spaceS,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  overflow: .ellipsis,
                  style: TextStyle(
                    fontSize: fontSize ?? context.setSize(14),
                    color: textColor ?? colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onActionPressed != null)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onActionPressed,
                    borderRadius: BorderRadius.circular(context.radiusS),
                    child: Padding(
                      padding: context.insetsAllS,
                      child: Text(
                        actionText ?? context.l10n.viewAll,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: context.colorScheme.primary,
                          fontSize: context.setSize(13),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: context.spaceXs),
      ],
    );
  }
}
