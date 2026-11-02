import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:status_saver/core/utils/extensions/context_extension.dart';
import 'package:status_saver/core/utils/extensions/responsive_values.dart';
import 'package:status_saver/core/utils/helpers/ui/bottom_sheet_helper.dart';
import 'package:status_saver/shared/widgets/cards/my_card.dart';
import 'package:status_saver/shared/widgets/misc/my_icon.dart';
import 'package:status_saver/shared/widgets/sheets/my_bottom_sheet.dart';

class MyIconPicker extends StatelessWidget {
  final IconData? selectedIcon;
  final ValueChanged<IconData> onIconSelected;

  const MyIconPicker({
    super.key,
    this.selectedIcon,
    required this.onIconSelected,
  });

  static Future<IconData?> show({
    required BuildContext context,
    IconData? selectedIcon,
  }) async {
    return BottomSheetHelper.show<IconData>(
      child: MyIconPicker(
        selectedIcon: selectedIcon,
        onIconSelected: (icon) => BottomSheetHelper.dismiss(result: icon),
      ),
    );
  }

  // Curated Iconsax icons relevant to customer categories.
  static final List<IconData> curatedIcons = [
    // People
    Iconsax.user,
    Iconsax.profile_2user,

    // Finance
    Iconsax.money_2,
    Iconsax.wallet_3,
    Iconsax.card,
    Iconsax.chart_2,

    // Business & Shopping
    Iconsax.shop,
    Iconsax.shop_add,
    Iconsax.shopping_cart,
    Iconsax.bag_2,
    Iconsax.box,

    // Home & Services
    Iconsax.home_2,
    Iconsax.building_4,
    Iconsax.setting_2,

    // Food
    Iconsax.coffee,
    Iconsax.cake,
    Iconsax.reserve,

    // Transport & Travel
    Iconsax.car,
    Iconsax.truck,
    Iconsax.airplane,

    // Education & Work
    Iconsax.book,
    Iconsax.briefcase,

    // Health & Lifestyle
    Iconsax.health,
    Iconsax.heart,
    Iconsax.game,
  ];

  static IconData? getIconByCodePoint(String? codePointStr) {
    if (codePointStr == null) return null;
    final codePoint = int.tryParse(codePointStr);
    if (codePoint == null) return null;

    try {
      return curatedIcons.firstWhere((icon) => icon.codePoint == codePoint);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyBottomSheet(
      title: context.l10n.selectIcon,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: context.spaceM,
          mainAxisSpacing: context.spaceM,
        ),
        itemCount: curatedIcons.length,
        itemBuilder: (context, index) {
          final icon = curatedIcons[index];
          final isSelected = icon == selectedIcon;

          return MyCard.filled(
            onTap: () => onIconSelected(icon),
            color: isSelected ? context.colorScheme.primary : null,
            child: MyIcon(
              icon: icon,
              color: isSelected ? context.colorScheme.onPrimary : null,
            ),
          );
        },
      ),
    );
  }
}
