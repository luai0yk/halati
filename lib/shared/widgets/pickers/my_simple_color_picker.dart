import 'package:flutter/material.dart';
import 'package:halati/core/constants/app_icons.dart';
import 'package:halati/core/utils/extensions/context_extension.dart';
import 'package:halati/core/utils/extensions/responsive_size.dart';
import 'package:halati/core/utils/extensions/responsive_values.dart';
import 'package:halati/core/utils/helpers/ui/bottom_sheet_helper.dart';
import 'package:halati/shared/widgets/cards/my_card.dart';
import 'package:halati/shared/widgets/misc/my_icon.dart';
import 'package:halati/shared/widgets/sheets/my_bottom_sheet.dart';

class MySimpleColorPicker extends StatelessWidget {
  final Color? selectedColor;
  final ValueChanged<Color> onColorSelected;

  const MySimpleColorPicker({
    super.key,
    this.selectedColor,
    required this.onColorSelected,
  });

  static Future<Color?> show({
    required BuildContext context,
    Color? selectedColor,
  }) async {
    return BottomSheetHelper.show<Color>(
      isScrollControlled: true,
      child: MySimpleColorPicker(
        selectedColor: selectedColor,
        onColorSelected: (color) => BottomSheetHelper.dismiss(result: color),
      ),
    );
  }

  // Premium, balanced colors for category tags.
  // Chosen to be visually distinct, modern, and comfortable in both
  // light and dark themes.
  static const List<Color> _curatedColors = [
    Color(0xFFEF6C6C), // Coral Red
    Color(0xFFE875A0), // Rose Pink
    Color(0xFFB06AB3), // Soft Purple
    Color(0xFF7C6BC4), // Violet
    Color(0xFF5C6BC0), // Indigo
    Color(0xFF4F83CC), // Royal Blue
    Color(0xFF4FA3D1), // Sky Blue
    Color(0xFF42A5B5), // Aqua
    Color(0xFF3FAF9F), // Teal
    Color(0xFF4EAF73), // Emerald
    Color(0xFF7CBF67), // Soft Green
    Color(0xFFA8B85A), // Olive
    Color(0xFFD0B04A), // Golden
    Color(0xFFE0A04B), // Amber
    Color(0xFFE27B4E), // Tangerine
    Color(0xFFD96A5F), // Terracotta
    Color(0xFF9B7563), // Warm Brown
    Color(0xFF78909C), // Slate
    Color(0xFF455A64), // Charcoal
    Color(0xFF8D6E63), // Cocoa
    Color(0xFF9C7A3C), // Bronze
    Color(0xFF5F8F8B), // Dusty Sea
    Color(0xFF8B6FAE), // Heather
    Color(0xFFB77952), // Copper
    Color(0xFF527A9E), // Steel Blue
  ];

  @override
  Widget build(BuildContext context) {
    return MyBottomSheet(
      title: context.l10n.selectColor,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: context.spaceM,
          mainAxisSpacing: context.spaceM,
        ),
        itemCount: _curatedColors.length,
        itemBuilder: (context, index) {
          final color = _curatedColors[index];
          final isSelected =
              selectedColor != null &&
              selectedColor!.toARGB32() == color.toARGB32();

          return MyCard.filled(
            onTap: () => onColorSelected(color),
            color: color,
            borderColor: isSelected ? context.colorScheme.outlineVariant : null,
            borderWidth: context.setSize(2),
            child: isSelected
                ? MyIcon(
                    icon: AppIcons.check,
                    color: color.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                    size: context.setSize(30),
                  )
                : SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
