import 'package:flutter/material.dart';
import 'package:flutter_app_template/core/utils/extensions/context_extension.dart';
import 'package:flutter_app_template/core/utils/extensions/responsive_size.dart';
import 'package:flutter_app_template/core/utils/extensions/responsive_values.dart';
import 'package:flutter_app_template/shared/widgets/cards/my_card.dart';
import 'package:flutter_app_template/shared/widgets/texts/text_separator.dart';

class MySectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Color? color;
  final bool? showDividers;

  const MySectionCard({
    super.key,
    required this.title,
    required this.children,
    this.color,
    this.showDividers,
  });

  @override
  Widget build(BuildContext context) {
    final isTransparent = color == Colors.transparent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextSeparator(
          text: title.toUpperCase(),
          textColor: context.colorScheme.primary,
          top: 0,
          bottom: context.spaceS,
        ),
        if (isTransparent)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _buildChildrenWithDividers(context),
          )
        else
          MyCard.filled(
            color: color,
            padding: EdgeInsets.zero,
            child: Column(children: _buildChildrenWithDividers(context)),
          ),
      ],
    );
  }

  List<Widget> _buildChildrenWithDividers(BuildContext context) {
    final bool shouldDivide = showDividers ?? (color != Colors.transparent);
    final List<Widget> result = [];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (shouldDivide && i < children.length - 1) {
        result.add(
          Divider(
            indent: context.setSize(55),
            endIndent: context.setSize(55),
            height: 0,
          ),
        );
      }
    }
    return result;
  }
}
