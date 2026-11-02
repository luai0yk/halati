import 'package:flutter/material.dart';
import 'package:flutter_app_template/core/constants/app_assets.dart';
import 'package:flutter_app_template/core/constants/app_icons.dart';
import 'package:flutter_app_template/core/routes/app_routes.dart';
import 'package:flutter_app_template/core/utils/extensions/context_extension.dart';
import 'package:flutter_app_template/core/utils/extensions/responsive_values.dart';
import 'package:flutter_app_template/core/utils/helpers/ui/bottom_sheet_helper.dart';
import 'package:flutter_app_template/core/utils/helpers/ui/dialog_helper.dart';
import 'package:flutter_app_template/core/utils/helpers/ui/snackbar_helper.dart';
import 'package:flutter_app_template/core/utils/helpers/ui/toast_helper.dart';
import 'package:flutter_app_template/shared/controller/image_picker_controller.dart';
import 'package:flutter_app_template/shared/controller/segment_button_controller.dart';
import 'package:flutter_app_template/shared/widgets/appbars/my_sliver_app_bar.dart';
import 'package:flutter_app_template/shared/widgets/buttons/my_button.dart';
import 'package:flutter_app_template/shared/widgets/buttons/my_favorite_button.dart';
import 'package:flutter_app_template/shared/widgets/buttons/my_icon_button.dart';
import 'package:flutter_app_template/shared/widgets/buttons/my_popup_menu.dart';
import 'package:flutter_app_template/shared/widgets/buttons/my_segment_button.dart';
import 'package:flutter_app_template/shared/widgets/cards/my_card.dart';
import 'package:flutter_app_template/shared/widgets/chips/animated_chip.dart';
import 'package:flutter_app_template/shared/widgets/dialogs/my_dialog.dart';
import 'package:flutter_app_template/shared/widgets/dialogs/my_progress_dialog.dart';
import 'package:flutter_app_template/shared/widgets/images/my_image.dart';
import 'package:flutter_app_template/shared/widgets/input/my_checkbox.dart';
import 'package:flutter_app_template/shared/widgets/input/my_dropdown_field.dart';
import 'package:flutter_app_template/shared/widgets/input/my_radio.dart';
import 'package:flutter_app_template/shared/widgets/input/my_switch.dart';
import 'package:flutter_app_template/shared/widgets/input/my_text_field.dart';
import 'package:flutter_app_template/shared/widgets/lists/selectable_chip_list.dart';
import 'package:flutter_app_template/shared/widgets/lists/selectable_list.dart';
import 'package:flutter_app_template/shared/widgets/misc/info_row.dart';
import 'package:flutter_app_template/shared/widgets/misc/my_avatar.dart';
import 'package:flutter_app_template/shared/widgets/misc/my_bottom_navigation_bar.dart';
import 'package:flutter_app_template/shared/widgets/misc/my_dot_indicator.dart';
import 'package:flutter_app_template/shared/widgets/misc/my_empty_state.dart';
import 'package:flutter_app_template/shared/widgets/misc/my_icon.dart';
import 'package:flutter_app_template/shared/widgets/misc/my_snackbar.dart';
import 'package:flutter_app_template/shared/widgets/misc/my_stepper.dart';
import 'package:flutter_app_template/shared/widgets/misc/my_toast.dart';
import 'package:flutter_app_template/shared/widgets/pickers/my_color_picker.dart';
import 'package:flutter_app_template/shared/widgets/pickers/my_date_range_picker.dart';
import 'package:flutter_app_template/shared/widgets/pickers/my_date_time_picker.dart';
import 'package:flutter_app_template/shared/widgets/pickers/my_icon_picker.dart';
import 'package:flutter_app_template/shared/widgets/pickers/my_image_picker.dart';
import 'package:flutter_app_template/shared/widgets/pickers/my_simple_color_picker.dart';
import 'package:flutter_app_template/shared/widgets/sheets/my_bottom_sheet.dart';
import 'package:flutter_app_template/shared/widgets/texts/inline_text_action.dart';
import 'package:flutter_app_template/shared/widgets/texts/text_separator.dart';
import 'package:flutter_app_template/shared/widgets/tiles/my_action_tile.dart';
import 'package:flutter_app_template/shared/widgets/tiles/my_checkbox_tile.dart';
import 'package:flutter_app_template/shared/widgets/tiles/my_expansion_tile.dart';
import 'package:flutter_app_template/shared/widgets/tiles/my_list_tile.dart';
import 'package:flutter_app_template/shared/widgets/tiles/my_radio_tile.dart';
import 'package:flutter_app_template/shared/widgets/tiles/my_switch_tile.dart';
import 'package:get/get.dart' hide SnackbarStatus;

class AppShellPage extends StatefulWidget {
  const AppShellPage({super.key});

  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage> {
  final ImagePickerController _imagePickerCtr = ImagePickerController();
  final GlobalKey<FormState> _requiredFormKey = GlobalKey<FormState>();
  int _currentIndex = 0;
  int _activeDotIndex = 0;
  int _activeStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: MyBottomNavigationBar(
        itemAnimation: .bounce,
        currentIndex: _currentIndex,
        border: Border(
          top: BorderSide(
            color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        borderRadius: .vertical(top: .circular(15)),
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          MyBottomNavigationBarItem(
            title: 'Home',
            icon: Icon(AppIcons.home),
            selectedIcon: Icon(AppIcons.homeFilled),
          ),
          MyBottomNavigationBarItem(
            title: 'Search',
            icon: Icon(AppIcons.search),
            selectedIcon: Icon(AppIcons.searchFilled),
          ),
          MyBottomNavigationBarItem(
            title: 'Profile',
            icon: Icon(AppIcons.user),
            selectedIcon: Icon(AppIcons.userFilled),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          MySliverAppBar.expanded(
            title: 'Widgets Catalog',
            pinned: true,
            expandedHeight: 150,
            hideTitleWhenExpanded: true,
            hideActionsWhenExpanded: false,
            isElevated: true,
            actions: [
              MyIconButton.solid(
                icon: AppIcons.settings,
                onPressed: () => Get.toNamed(AppRoutes.settings),
                iconColor: context.colorScheme.primary,
                backgroundColor: context.colorScheme.onPrimary.withValues(
                  alpha: .8,
                ),
              ),
            ],
            expandedContent: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to',
                    style: TextStyle(
                      fontSize: 16,
                      color: context.colorScheme.onPrimary.withValues(
                        alpha: 0.8,
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Flutter App Template',
                    style: TextStyle(
                      fontSize: 20,
                      color: context.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            background: Container(color: context.colorScheme.primary),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.list(
              children: [
                _buildButtonsSection(context),
                const SizedBox(height: 12),
                _buildSegmentButtonsSection(),
                const SizedBox(height: 12),
                _buildCardsSection(context),
                const SizedBox(height: 12),
                _buildChipsSection(context),
                const SizedBox(height: 12),
                _buildDialogsSection(context),
                const SizedBox(height: 12),
                _buildImagesSection(context),
                const SizedBox(height: 12),
                _buildListsSection(context),
                const SizedBox(height: 12),
                _buildInputsSection(context),
                const SizedBox(height: 12),
                _buildMiscSection(context),
                const SizedBox(height: 12),
                _buildSheetsSection(context),
                const SizedBox(height: 12),
                _buildPickersSection(context),
                const SizedBox(height: 12),
                _buildTextsSection(context),
                const SizedBox(height: 12),
                _buildTilesSection(context),
                const SizedBox(height: 12),
                _buildRequiredWidgetsSection(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonsSection(BuildContext context) {
    return MyExpansionTile(
      title: 'Buttons',
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'MyButton Variants',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              MyButton.primary(
                text: 'Primary Button',
                onPressed: () {},
                prefixIcon: AppIcons.checkSquare,
              ),
              const SizedBox(height: 8),
              MyButton.outlined(
                text: 'Outlined Button',
                onPressed: () {},
                suffixIcon: AppIcons.arrowBack(context),
              ),
              const SizedBox(height: 8),
              MyButton.outlinedNeutral(
                text: 'Outlined Neutral Button',
                onPressed: () {},
                prefixIcon: AppIcons.settings,
              ),
              const SizedBox(height: 8),
              MyButton.text(text: 'Text Button', onPressed: () {}),
              const Divider(height: 32),

              const Text(
                'MyButton States',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              MyButton.primary(
                text: 'Loading Primary',
                onPressed: () async =>
                    await Future.delayed(const Duration(seconds: 3)),
              ),
              const SizedBox(height: 8),
              MyButton.outlined(
                text: 'Loading Outlined',
                onPressed: () async =>
                    await Future.delayed(const Duration(seconds: 3)),
              ),
              const SizedBox(height: 8),
              MyButton.primary(
                text: 'Disabled Button',
                isDisabled: true,
                onPressed: () {},
              ),
              const SizedBox(height: 8),
              MyButton.primary(
                text: 'Resend Code',
                timerSeconds: 30,
                onPressed: () {},
              ),
              const Divider(height: 32),

              const Text(
                'MyFavoriteButton',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  MyFavoriteButton(
                    initialIsFavorite: false,
                    onChanged: (isFav) {
                      ToastHelper.show(msg: 'Favorite toggled: $isFav');
                    },
                  ),
                  const SizedBox(width: 12),
                  MyFavoriteButton(
                    initialIsFavorite: true,
                    onChanged: (isFav) {
                      ToastHelper.show(msg: 'Favorite toggled: $isFav');
                    },
                  ),
                ],
              ),
              const Divider(height: 32),

              const Text(
                'MyIconButton Variants',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  MyIconButton.solid(icon: AppIcons.add, onPressed: () {}),
                  MyIconButton.outlined(icon: AppIcons.minus, onPressed: () {}),
                  MyIconButton.ghost(icon: AppIcons.delete, onPressed: () {}),
                  StatefulBuilder(
                    builder: (context, setState) {
                      bool selected = false;
                      return MyIconButton.bordered(
                        icon: AppIcons.favorite,
                        isSelected: selected,
                        onPressed: () => setState(() => selected = !selected),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  MyIconButton.solid(
                    icon: AppIcons.refresh,
                    onPressed: () async =>
                        await Future.delayed(const Duration(seconds: 3)),
                  ),
                  MyIconButton.outlined(
                    icon: AppIcons.refresh,
                    onPressed: () async =>
                        await Future.delayed(const Duration(seconds: 3)),
                  ),
                  MyIconButton.solid(icon: AppIcons.clear, onPressed: null),
                ],
              ),
              const Divider(height: 32),

              const Text(
                'MyPopupMenu',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: MyPopupMenu<String>(
                  // elevation: 0,
                  onSelected: (value) {
                    ToastHelper.show(msg: value);
                  },
                  items: [
                    MyPopupMenuItem(
                      value: 'edit',
                      label: 'Edit',
                      icon: AppIcons.edit,
                    ),
                    MyPopupMenuItem(
                      value: 'delete',
                      label: 'Delete',
                      icon: AppIcons.delete,
                      color: context.extendedColors.danger.color,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardsSection(BuildContext context) {
    return MyExpansionTile(
      title: 'Cards',
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MyCard.elevated(
                padding: const EdgeInsets.all(16),
                child: const Text('Elevated Card - Has drop shadow.'),
              ),
              const SizedBox(height: 12),
              MyCard.outlined(
                padding: const EdgeInsets.all(16),
                child: const Text('Outlined Card - Uses neutral border.'),
              ),
              const SizedBox(height: 12),
              MyCard.filled(
                padding: const EdgeInsets.all(16),
                child: const Text('Filled Card - Subtle background color.'),
              ),
              const SizedBox(height: 12),
              MyCard.bordered(
                padding: const EdgeInsets.all(16),
                child: const Text('Bordered Card - Typically primary border.'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChipsSection(BuildContext context) {
    return MyExpansionTile(
      title: 'Chips',
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: StatefulBuilder(
            builder: (context, setState) {
              bool c1 = true;
              bool c2 = false;
              bool c3 = false;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AnimatedChip(
                    text: 'Selected Chip',
                    isSelected: c1,
                    onTap: () => setState(() => c1 = !c1),
                  ),
                  AnimatedChip(
                    text: 'Unselected Chip',
                    isSelected: c2,
                    onTap: () => setState(() => c2 = !c2),
                  ),
                  AnimatedChip(
                    text: 'With Icon',
                    isSelected: c3,
                    prefixIcon: AppIcons.star,
                    onTap: () => setState(() => c3 = !c3),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDialogsSection(BuildContext context) {
    return MyExpansionTile(
      title: 'Dialogs',
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Standard & Status Dialogs',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              SelectableChipList<DialogStatus>.single(
                items: [
                  SelectableChip(
                    value: DialogStatus.standard,
                    title: 'Standard',
                  ),
                  SelectableChip(value: DialogStatus.success, title: 'Success'),
                  SelectableChip(value: DialogStatus.warning, title: 'Warning'),
                  SelectableChip(value: DialogStatus.danger, title: 'Danger'),
                  SelectableChip(value: DialogStatus.info, title: 'Info'),
                ],
                onChanged: (value) {
                  DialogHelper.show(
                    child: MyDialog(
                      title: '${value.name.capitalizeFirst} Dialog',
                      content:
                          'This is a beautifully designed ${value.name} dialog that perfectly aligns with the design system.',
                      status: value,
                      primaryButton: DialogButton(
                        text: 'Confirm',
                        onPressed: () async =>
                            await Future.delayed(const Duration(seconds: 2)),
                      ),
                      secondaryButton: const DialogButton(text: 'Cancel'),
                    ),
                  );
                },
              ),
              const Divider(height: 32),

              const Text(
                'Progress Dialog',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              MyButton.outlinedNeutral(
                text: 'Show Progress Dialog',
                onPressed: () {
                  DialogHelper.show(
                    child: const MyProgressDialog(
                      message: 'Loading your data...',
                    ),
                  );
                  Future.delayed(const Duration(seconds: 5), () {
                    if (context.mounted) DialogHelper.dismiss();
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagesSection(BuildContext context) {
    return MyExpansionTile(
      title: 'Images',
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Network Image with Skeleton',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              const MyImage.network(
                url:
                    'https://images.unsplash.com/photo-1548839140-29a749e1cf4d?w=800&q=80',
                height: 150,
                width: 150,
                isViewable: true,
              ),
              const Divider(height: 32),

              const Text(
                'Asset Image with Border',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              MyImage.asset(
                asset: AppAssets.testImage,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                borderColor: context.colorScheme.primary,
                borderWidth: 2,
                padding: const EdgeInsets.all(4),
              ),
              const Divider(height: 32),

              const Text(
                'Circular Asset Image',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Center(
                child: MyImage.asset(
                  asset: AppAssets.testImage,
                  height: 150,
                  width: 150,
                  borderColor: context.colorScheme.primary,
                  borderRadius: const BorderRadius.all(Radius.circular(99)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListsSection(BuildContext context) {
    return MyExpansionTile(
      title: 'Lists',
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Selectable Chip List',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              SelectableChipList<String>.multi(
                items: [
                  SelectableChip(value: '1', title: 'Option 1'),
                  SelectableChip(value: '2', title: 'Option 2'),
                  SelectableChip(value: '3', title: 'Option 3'),
                ],
                initialSelected: const ['1'],
                onChanged: (selected) {},
              ),
              const Divider(height: 32),

              const Text(
                'Selectable List (Searchable)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              MyButton.outlinedNeutral(
                text: 'Open Multi-Select List',
                onPressed: () {
                  DialogHelper.show(
                    child: MyDialog(
                      title: 'Select Items',
                      height: 400,
                      customContent: SelectableList<int>.multi(
                        enableSearch: true,
                        items: List.generate(20, (index) => index + 1),
                        initialSelected: const [2, 5, 8],
                        itemLabel: (item) => 'Item number $item',
                        onChanged: (selected) {},
                      ),
                      primaryButton: const DialogButton(text: 'Done'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiscSection(BuildContext context) {
    return MyExpansionTile(
      title: 'Misc',
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'InfoRow',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              InfoRow(
                label: 'Available Balance',
                value: '\$12,450.00',
                icon: AppIcons.phone,
                valueColor: context.colorScheme.primary,
              ),
              InfoRow(
                label: 'Active Users',
                value: '142',
                icon: AppIcons.user,
                valueColor: context.extendedColors.danger.color,
              ),
              const Divider(height: 32),

              const Text(
                'MyIcon',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                children: [
                  MyIcon(icon: AppIcons.favorite),
                  MyIcon(icon: AppIcons.favorite, filled: true),
                  MyIcon(
                    icon: AppIcons.favorite,
                    color: context.extendedColors.danger.color,
                  ),
                  MyIcon(
                    icon: AppIcons.favorite,
                    filled: true,
                    color: context.extendedColors.danger.color,
                  ),
                ],
              ),
              const Divider(height: 32),

              const Text(
                'MyEmptyState',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              MyEmptyState(
                icon: AppIcons.search,
                title: 'No Results Found',
                subtitle:
                    'We couldn\'t find anything matching your search criteria. Please try again.',
                actionText: 'Clear Search',
                onAction: () {},
              ),
              const Divider(height: 32),

              const Text(
                'MyToast',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              SelectableChipList<ToastStatus>.single(
                items: [
                  SelectableChip(
                    value: ToastStatus.standard,
                    title: 'Standard',
                  ),
                  SelectableChip(value: ToastStatus.success, title: 'Success'),
                  SelectableChip(value: ToastStatus.warning, title: 'Warning'),
                  SelectableChip(value: ToastStatus.danger, title: 'Danger'),
                  SelectableChip(value: ToastStatus.info, title: 'Info'),
                ],
                onChanged: (value) {
                  ToastHelper.show(
                    msg: 'This is a ${value.name} toast message.',
                    status: value,
                    actionText: 'Undo',
                    onAction: () {},
                  );
                },
              ),
              const Divider(height: 32),

              const Text(
                'MySnackbar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              SelectableChipList<SnackBarStatus>.single(
                items: [
                  SelectableChip(
                    value: SnackBarStatus.standard,
                    title: 'Standard',
                  ),
                  SelectableChip(
                    value: SnackBarStatus.success,
                    title: 'Success',
                  ),
                  SelectableChip(
                    value: SnackBarStatus.warning,
                    title: 'Warning',
                  ),
                  SelectableChip(value: SnackBarStatus.danger, title: 'Danger'),
                  SelectableChip(value: SnackBarStatus.info, title: 'Info'),
                ],
                onChanged: (value) {
                  SnackBarHelper.show(
                    msg: 'This is a ${value.name} snackbar message.',
                    status: value,
                    actionText: 'Undo',
                    onAction: () {},
                  );
                },
              ),
              const Divider(height: 32),

              const Text(
                'MyAvatar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MyAvatar(name: 'John Doe', size: 48),
                  MyAvatar(name: 'أحمد علي', size: 48),
                  MyAvatar(icon: AppIcons.user, size: 48),
                  MyAvatar(icon: AppIcons.settings, size: 48),
                ],
              ),
              const Divider(height: 32),

              const Text(
                'MyDotIndicator (Multiple Effects)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  const Text(
                    'Expanding Effect',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  MyDotIndicator(
                    count: 5,
                    activeIndex: _activeDotIndex,
                    effect: DotIndicatorEffect.expanding,
                    onDotClicked: (idx) =>
                        setState(() => _activeDotIndex = idx),
                  ),
                  const SizedBox(height: 16),
                  const Text('Worm Effect', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),
                  MyDotIndicator(
                    count: 5,
                    activeIndex: _activeDotIndex,
                    effect: DotIndicatorEffect.worm,
                    onDotClicked: (idx) =>
                        setState(() => _activeDotIndex = idx),
                  ),
                  const SizedBox(height: 16),
                  const Text('Sliding Effect', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),
                  MyDotIndicator(
                    count: 5,
                    activeIndex: _activeDotIndex,
                    effect: DotIndicatorEffect.sliding,
                    onDotClicked: (idx) =>
                        setState(() => _activeDotIndex = idx),
                  ),
                ],
              ),
              const Divider(height: 32),

              const Text(
                'MyStepper',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              MyStepper(
                activeStep: _activeStep,
                onStepReached: (idx) => setState(() => _activeStep = idx),
                steps: const [
                  MyStep(icon: AppIcons.user, title: 'Profile'),
                  MyStep(icon: AppIcons.settings, title: 'Config'),
                  MyStep(icon: AppIcons.check, title: 'Done'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputsSection(BuildContext context) {
    return MyExpansionTile(
      title: 'Inputs',

      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'MyTextField',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              MyTextField(
                hintText: 'Search Field',
                isSearch: true,
                prefixIcon: AppIcons.search,
              ),
              const SizedBox(height: 12),
              MyTextField.plain(hintText: 'Plain Field (No border)'),
              const SizedBox(height: 12),
              MyTextField(
                labelText: 'Password Field',
                hintText: 'Enter password...',
                obscureText: true,
                prefixIcon: AppIcons.lock,
              ),
              const Divider(height: 32),

              const Text(
                'CustomDropdownField',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              MyDropdownField<String>(
                labelText: 'Standard Dropdown',
                hintText: 'Select an option...',
                prefixIcon: AppIcons.user,
                items: const [
                  MyDropdownItem(
                    value: '1',
                    label: 'Option 1',
                    icon: AppIcons.star,
                  ),
                  MyDropdownItem(
                    value: '2',
                    label: 'Option 2',
                    icon: AppIcons.favorite,
                    iconColor: Colors.red,
                  ),
                  MyDropdownItem(
                    value: '3',
                    label: 'Option 3',
                    icon: AppIcons.share,
                    iconColor: Colors.blue,
                  ),
                ],
                onChanged: (value, label) {
                  ToastHelper.show(msg: label!);
                },
              ),
              const SizedBox(height: 12),
              MyDropdownField<String>(
                labelText: 'Searchable Dropdown',
                hintText: 'Select an option...',
                enableSearch: true,
                items: const [
                  MyDropdownItem(value: '1', label: 'Apple'),
                  MyDropdownItem(value: '2', label: 'Banana'),
                  MyDropdownItem(value: '3', label: 'Cherry'),
                  MyDropdownItem(value: '4', label: 'Date'),
                  MyDropdownItem(value: '5', label: 'Elderberry'),
                  MyDropdownItem(value: '6', label: 'Fig'),
                  MyDropdownItem(value: '7', label: 'Grape'),
                ],
                onChanged: (value, label) {
                  ToastHelper.show(msg: label!);
                },
              ),
              const Divider(height: 32),

              const Text(
                'Selection Controls',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Builder(
                builder: (context) {
                  bool checkboxVal = true;
                  int radioVal = 1;
                  bool switchVal = true;

                  return StatefulBuilder(
                    builder: (context, setState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Standalone
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              MyCheckbox(
                                value: checkboxVal,
                                onChanged: (val) =>
                                    setState(() => checkboxVal = val),
                              ),
                              MyRadio<int>(
                                value: 1,
                                groupValue: radioVal,
                                onChanged: (val) =>
                                    setState(() => radioVal = val),
                              ),
                              MyRadio<int>(
                                value: 2,
                                groupValue: radioVal,
                                onChanged: (val) =>
                                    setState(() => radioVal = val),
                              ),
                              MySwitch(
                                value: switchVal,
                                onChanged: (val) =>
                                    setState(() => switchVal = val),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Tiles
                          MyCheckboxTile(
                            title: 'Checkbox Tile',
                            subtitle: 'Tap anywhere on the tile to toggle',
                            value: checkboxVal,
                            onChanged: (val) =>
                                setState(() => checkboxVal = val),
                          ),
                          const SizedBox(height: 8),
                          MyRadioTile<int>(
                            title: 'Radio Tile Option 1',
                            subtitle: 'Selects the first radio option',
                            value: 1,
                            groupValue: radioVal,
                            onChanged: (val) => setState(() => radioVal = val),
                          ),
                          const SizedBox(height: 8),
                          MyRadioTile<int>(
                            title: 'Radio Tile Option 2',
                            subtitle: 'Selects the second radio option',
                            value: 2,
                            groupValue: radioVal,
                            onChanged: (val) => setState(() => radioVal = val),
                          ),
                          const SizedBox(height: 8),
                          MySwitchTile(
                            title: 'Switch Tile',
                            subtitle: 'Enable or disable the setting',
                            value: switchVal,
                            onChanged: (val) => setState(() => switchVal = val),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSheetsSection(BuildContext context) {
    return MyExpansionTile(
      title: 'Sheets',
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'MyBottomSheet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              SelectableChipList<BottomSheetStatus>.single(
                items: [
                  SelectableChip(
                    value: BottomSheetStatus.standard,
                    title: 'Standard',
                  ),
                  SelectableChip(
                    value: BottomSheetStatus.success,
                    title: 'Success',
                  ),
                  SelectableChip(
                    value: BottomSheetStatus.warning,
                    title: 'Warning',
                  ),
                  SelectableChip(
                    value: BottomSheetStatus.danger,
                    title: 'Danger',
                  ),
                  SelectableChip(value: BottomSheetStatus.info, title: 'Info'),
                ],
                onChanged: (value) {
                  BottomSheetHelper.show(
                    child: MyBottomSheet(
                      title: '${value.name.capitalizeFirst} Settings',
                      status: value,
                      primaryButton: SheetButton(
                        text: 'Save Changes',
                        onPressed: () async {
                          await Future.delayed(const Duration(seconds: 2));
                        },
                      ),
                      secondaryButton: const SheetButton(text: 'Cancel'),
                      child: Text(
                        'This is a beautifully designed ${value.name} bottom sheet that seamlessly matches the design system.',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPickersSection(BuildContext context) {
    return MyExpansionTile(
      title: 'Pickers',
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'DateTimePicker',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  MyButton.outlinedNeutral(
                    text: 'Pick Date',
                    onPressed: () => MyDateTimePicker.show(
                      context: context,
                      mode: MyDateBottomPickerMode.date,
                      onDateChanged: (v) {},
                    ),
                  ),
                  MyButton.outlinedNeutral(
                    text: 'Pick Time',
                    onPressed: () => MyDateTimePicker.show(
                      context: context,
                      mode: MyDateBottomPickerMode.time,
                      onDateChanged: (v) {},
                    ),
                  ),
                  MyButton.outlinedNeutral(
                    text: 'Pick Both',
                    onPressed: () => MyDateTimePicker.show(
                      context: context,
                      mode: MyDateBottomPickerMode.dateTime,
                      onDateChanged: (v) {},
                    ),
                  ),
                  MyButton.outlinedNeutral(
                    text: 'Pick Date Range',
                    onPressed: () => MyDateRangePicker.show(
                      context: context,
                      onDateRangeChanged: (v) {
                        ToastHelper.show(
                          msg:
                              'Selected: ${v.start.toString().split(' ')[0]} - ${v.end.toString().split(' ')[0]}',
                        );
                      },
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),

              const Text(
                'MyColorPicker',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  MyButton.outlinedNeutral(
                    text: 'Full Color Picker',
                    onPressed: () {
                      MyColorPicker.show(
                        context: context,
                        initialColor: context.colorScheme.primary,
                        onColorChanged: (color) {
                          ToastHelper.show(
                            msg: color.toARGB32().toRadixString(16),
                          );
                        },
                      );
                    },
                  ),
                  MyButton.outlinedNeutral(
                    text: 'Simple Color Palette',
                    onPressed: () {
                      MySimpleColorPicker.show(
                        context: context,
                        selectedColor: context.colorScheme.primary,
                      );
                    },
                  ),
                  MyButton.outlinedNeutral(
                    text: 'Curated Icon Picker',
                    onPressed: () {
                      MyIconPicker.show(
                        context: context,
                        selectedIcon: AppIcons.settings,
                      );
                    },
                  ),
                ],
              ),
              const Divider(height: 32),

              const Text(
                'My Image Picker',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              MyImagePicker(
                controller: _imagePickerCtr,
                borderRadius: BorderRadius.circular(12),
                width: .infinity,
                onChanged: (file) {
                  if (file != null) {
                    ToastHelper.show(
                      msg: 'Selected image: ${file.path.split('/').last}',
                    );
                  } else {
                    ToastHelper.show(msg: 'Image cleared');
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextsSection(BuildContext context) {
    return MyExpansionTile(
      title: 'Texts',
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'InlineTextAction',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              InlineTextAction(
                text: 'Don\'t have an account? ',
                actionText: 'Sign up here',
                onTap: () {},
              ),
              const Divider(height: 32),

              const Text(
                'TextSeparator',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              const TextSeparator(text: 'OR'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTilesSection(BuildContext context) {
    return MyExpansionTile(
      title: 'Tiles',
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'MyListTile',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              MyListTile(
                title: 'John Doe',
                subtitle: 'Software Engineer',
                leadingIcon: AppIcons.user,
                trailing: MyIcon(icon: AppIcons.arrowBack(context)),
              ),
              const Divider(height: 32),

              const Text(
                'MyActionTile',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              MyActionTile(
                icon: AppIcons.settings,
                title: 'Account Settings',
                onTap: () {},
              ),
              const SizedBox(height: 8),
              MyActionTile(
                icon: AppIcons.delete,
                color: context.extendedColors.danger.color,
                title: 'Delete Account',
                onTap: () {},
              ),
              const Divider(height: 32),

              const Text(
                'MyExpansionTile',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              const MyExpansionTile(
                title: 'Nested Expansion Tile',
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'This is the content inside the nested expansion tile.',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentButtonsSection() {
    final defaultCtr = SegmentButtonController<String>(initial: 'Day');
    final scrollableCtr = SegmentButtonController<int>(initial: 4);

    return MyExpansionTile(
      title: 'Segment Buttons',
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Standard Segment Button',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              MySegmentButton<String>(
                controller: defaultCtr,
                backgroundColor: context.colorScheme.surfaceContainer,
                size: .small,
                borderColor: context.colorScheme.outlineVariant,
                borderRadius: context.brM,
                segments: [
                  MyButtonSegment(value: 'Day', label: 'Day'),
                  MyButtonSegment(value: 'Week', label: 'Week'),
                  MyButtonSegment(value: 'Month', label: 'Month'),
                ],
              ),
              const Divider(height: 32),
              const Text(
                'Scrollable Segment Button',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              MySegmentButton<int>(
                controller: scrollableCtr,
                scrollable: true,
                backgroundColor: context.colorScheme.surfaceContainer,
                segments: [
                  MyButtonSegment(
                    value: 1,
                    label: 'One',
                    icon: AppIcons.star,
                    color: Colors.amber,
                  ),
                  MyButtonSegment(
                    value: 2,
                    label: 'Two',
                    icon: AppIcons.favorite,
                    color: Colors.redAccent,
                  ),
                  MyButtonSegment(
                    value: 3,
                    label: 'Three',
                    icon: AppIcons.home,
                    color: Colors.blueAccent,
                  ),
                  MyButtonSegment(
                    value: 4,
                    label: 'Four',
                    icon: AppIcons.settings,
                    color: Colors.teal,
                  ),
                  MyButtonSegment(
                    value: 5,
                    label: 'Five',
                    icon: AppIcons.user,
                    color: Colors.indigo,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequiredWidgetsSection(BuildContext context) {
    return MyExpansionTile(
      title: 'Required Widgets Testing',
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _requiredFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Form Validation',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                Center(
                  child: MyImagePicker(
                    borderRadius: .circular(999),
                    pickIcon: AppIcons.user,
                    controller: _imagePickerCtr,
                    label: 'Profile Picture',
                    isRequired: true,
                  ),
                ),
                const SizedBox(height: 24),
                MyTextField(
                  labelText: 'Name',
                  hintText: 'Enter your name',
                  isRequired: true,
                  prefixIcon: AppIcons.user,
                ),
                const SizedBox(height: 12),
                MyDropdownField<String>(
                  labelText: 'Role',
                  hintText: 'Select a role...',
                  isRequired: true,
                  prefixIcon: AppIcons.settings,
                  items: const [
                    MyDropdownItem(value: 'admin', label: 'Admin'),
                    MyDropdownItem(value: 'editor', label: 'Editor'),
                    MyDropdownItem(value: 'viewer', label: 'Viewer'),
                  ],
                ),
                const SizedBox(height: 12),
                MyButton.primary(
                  text: 'Submit Form',
                  onPressed: () {
                    if (_requiredFormKey.currentState?.validate() ?? false) {
                      ToastHelper.show(
                        msg: 'Form submitted successfully!',
                        status: ToastStatus.success,
                      );
                    } else {
                      ToastHelper.show(
                        msg: 'Please fill in all required fields.',
                        status: ToastStatus.danger,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
