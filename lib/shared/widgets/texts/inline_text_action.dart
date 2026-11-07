import 'package:flutter/material.dart';
import 'package:halati/core/utils/extensions/context_extension.dart';
import 'package:halati/core/utils/extensions/responsive_size.dart';
import 'package:halati/core/utils/extensions/responsive_values.dart';

class InlineTextAction extends StatelessWidget {
  /// The main texts to display before the action button.
  final String text;

  /// The texts to display as the action button.
  final String actionText;

  /// The callback function to execute when the action button is tapped.
  final Function() onTap;

  /// To determine whether the button is enabled or not.
  /// Default to `true`
  final bool? isActionEnabled;

  const InlineTextAction({
    super.key,
    required this.text,
    required this.actionText,
    required this.onTap,
    this.isActionEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colorScheme;
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: context.setSize(16),
          color: colors.onSurface,
        ),
        children: [
          TextSpan(text: text),
          WidgetSpan(
            alignment: .middle,
            child: Container(
              margin: context.insetsHorizontalXs,
              child: InkWell(
                onTap: isActionEnabled! ? onTap : null,
                borderRadius: context.brXs,
                child: Padding(
                  padding: .symmetric(horizontal: context.spaceXs),
                  child: Text(
                    actionText,
                    style: TextStyle(
                      color: isActionEnabled!
                          ? colors.primary
                          : colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
