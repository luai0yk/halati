import 'package:flutter/material.dart';
import 'package:flutter_app_template/core/theme/extended_colors.dart';
import 'package:flutter_app_template/core/constants/app_icons.dart';
import 'package:flutter_app_template/core/utils/extensions/context_extension.dart';
import 'package:flutter_app_template/core/utils/extensions/responsive_size.dart';
import 'package:flutter_app_template/core/utils/extensions/responsive_values.dart';
import 'package:flutter_app_template/shared/widgets/buttons/my_button.dart';
import 'package:flutter_app_template/shared/widgets/buttons/my_icon_button.dart';
import 'package:flutter_app_template/shared/widgets/cards/my_card.dart';
import 'package:flutter_app_template/shared/widgets/misc/my_icon.dart';

enum BottomSheetStatus { standard, success, warning, danger, info }

class SheetButton {
  final String text;
  final Function()? onPressed;
  final IconData? prefixIcon;
  final IconData? suffixIcon;

  /// If provided, disables the button and displays a countdown timer for this many seconds.
  final int? timerSeconds;

  /// Whether to automatically show a loading indicator and disable the button while an async [onPressed] callback executes.
  /// Defaults to `true`.
  final bool autoLoading;

  const SheetButton({
    required this.text,
    this.onPressed,
    this.prefixIcon,
    this.suffixIcon,
    this.timerSeconds,
    this.autoLoading = true,
  });
}

class MyBottomSheet extends StatefulWidget {
  /// The title of the bottom sheets.
  final String? title;

  /// The height of the bottom sheets.
  final double? sheetHeight;
  final bool openWithMaxHeight;

  /// The child widget to be displayed inside the bottom sheets.
  final Widget child;

  final EdgeInsets? padding;

  /// Whether to hide the handle at the top of the bottom sheets.
  /// Defaults to `true`
  final bool hideHandle;

  /// Primary button configuration.
  final SheetButton? primaryButton;

  /// Secondary button configuration.
  final SheetButton? secondaryButton;

  /// Whether pressing the primary or secondary buttons should automatically pop the bottom sheet.
  /// Defaults to true.
  final bool buttonsCanPopAutomatically;

  final BottomSheetStatus status;
  final IconData? statusIcon;

  const MyBottomSheet({
    super.key,
    this.title,
    this.sheetHeight,
    this.openWithMaxHeight = false,
    required this.child,
    this.padding,
    this.hideHandle = false,
    this.primaryButton,
    this.secondaryButton,
    this.buttonsCanPopAutomatically = true,
    this.status = BottomSheetStatus.standard,
    this.statusIcon,
  });

  @override
  State<MyBottomSheet> createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  Future<void> _handlePrimaryPressed() async {
    if (widget.primaryButton?.onPressed != null) {
      final result = widget.primaryButton!.onPressed!();
      if (result is Future) {
        await result;
      }
    }
    if (widget.buttonsCanPopAutomatically && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleSecondaryPressed() async {
    if (widget.secondaryButton?.onPressed != null) {
      final result = widget.secondaryButton!.onPressed!();
      if (result is Future) {
        await result;
      }
    }
    if (widget.buttonsCanPopAutomatically && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colorScheme;
    final ExtendedColors xColors = context.extendedColors;

    IconData? defaultIcon;
    Color? iconColor;

    switch (widget.status) {
      case BottomSheetStatus.success:
        defaultIcon = AppIcons.checkCircle;
        iconColor = colors.primary;
        break;
      case BottomSheetStatus.warning:
        defaultIcon = AppIcons.warning;
        iconColor = xColors.warning.color;
        break;
      case BottomSheetStatus.danger:
        defaultIcon = AppIcons.error;
        iconColor = xColors.danger.color;
        break;
      case BottomSheetStatus.info:
        defaultIcon = AppIcons.info;
        iconColor = xColors.info.color;
        break;
      case BottomSheetStatus.standard:
        defaultIcon = null;
        iconColor = null;
        break;
    }

    final displayIcon = widget.statusIcon ?? defaultIcon;
    final finalIconColor = iconColor ?? colors.primary;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: MyCard.filled(
          height: widget.openWithMaxHeight
              ? context.screenHeight * 0.95
              : widget.sheetHeight,
          constraints: BoxConstraints(
            maxHeight: context.screenHeight * 0.95,
            minHeight: context.screenHeight * 0.3,
          ),
          borderRadius: BorderRadius.only(
            topLeft: .circular(context.radiusL),
            topRight: .circular(context.radiusL),
          ),
          padding: EdgeInsets.only(top: widget.hideHandle ? context.spaceM : 0),
          color: colors.surface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!widget.hideHandle)
                      Padding(
                        padding: EdgeInsets.only(top: context.setSize(8)),
                        child: Center(
                          child: MyCard.filled(
                            height: context.setSize(4),
                            width: context.setSize(50),
                            margin: EdgeInsets.zero,
                            color: colors.outlineVariant,
                            child: const SizedBox(),
                          ),
                        ),
                      ),

                    if (widget.title != null || displayIcon != null) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.spaceM,
                          vertical: context.spaceS,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  if (displayIcon != null) ...[
                                    MyCard.filled(
                                      padding: context.insetsAllS,
                                      color: finalIconColor.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: context.brCircular,
                                      child: MyIcon(
                                        icon: displayIcon,
                                        color: finalIconColor,
                                        size: context.setSize(20),
                                      ),
                                    ),
                                    SizedBox(width: context.setSize(12)),
                                  ],
                                  if (widget.title != null)
                                    Expanded(
                                      child: Text(
                                        widget.title!,
                                        maxLines: 3,
                                        style: context.textTheme.titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: context.setSize(32),
                              width: context.setSize(32),
                              child: MyIconButton.solid(
                                icon: AppIcons.close,
                                tooltip: context.l10n.close,
                                iconSize: context.setSize(18),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    Flexible(
                      child: Padding(
                        padding:
                            widget.padding ??
                            EdgeInsets.symmetric(
                              horizontal: context.spaceM,
                              vertical: context.spaceS,
                            ),
                        child: widget.child,
                      ),
                    ),
                  ],
                ),
              ),

              if (widget.primaryButton != null ||
                  widget.secondaryButton != null) ...[
                Padding(
                  padding: context.insetsAllM,
                  child: Row(
                    children: [
                      if (widget.secondaryButton != null) ...[
                        Expanded(
                          flex: widget.primaryButton != null ? 1 : 0,
                          child: MyButton.outlinedNeutral(
                            onPressed: _handleSecondaryPressed,
                            text: widget.secondaryButton!.text,
                            prefixIcon: widget.secondaryButton!.prefixIcon,
                            suffixIcon: widget.secondaryButton!.suffixIcon,
                            timerSeconds: widget.secondaryButton!.timerSeconds,
                            autoLoading: widget.secondaryButton!.autoLoading,
                          ),
                        ),
                        if (widget.primaryButton != null)
                          SizedBox(width: context.spaceM),
                      ],
                      if (widget.primaryButton != null) ...[
                        Expanded(
                          flex: 2,
                          child: MyButton.primary(
                            onPressed: _handlePrimaryPressed,
                            text: widget.primaryButton!.text,
                            prefixIcon: widget.primaryButton!.prefixIcon,
                            suffixIcon: widget.primaryButton!.suffixIcon,
                            timerSeconds: widget.primaryButton!.timerSeconds,
                            autoLoading: widget.primaryButton!.autoLoading,
                            color: iconColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
