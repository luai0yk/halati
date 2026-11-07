import 'package:flutter/material.dart';
import 'package:halati/core/constants/app_icons.dart';
import 'package:halati/core/utils/extensions/context_extension.dart';
import 'package:halati/core/utils/extensions/responsive_size.dart';
import 'package:halati/core/utils/extensions/responsive_values.dart';
import 'package:halati/shared/widgets/buttons/my_button.dart';
import 'package:halati/shared/widgets/misc/my_icon.dart';

enum DialogStatus { standard, success, warning, danger, info }

class DialogButton {
  final String text;
  final Function()? onPressed;
  final IconData? prefixIcon;
  final IconData? suffixIcon;

  /// If provided, disables the button and displays a countdown timer for this many seconds.
  final int? timerSeconds;

  /// Whether to automatically show a loading indicator and disable the button while an async [onPressed] callback executes.
  /// Defaults to `true`.
  final bool autoLoading;

  const DialogButton({
    required this.text,
    this.onPressed,
    this.prefixIcon,
    this.suffixIcon,
    this.timerSeconds,
    this.autoLoading = true,
  });
}

class MyDialog extends StatefulWidget {
  final String? title, content;
  final DialogButton? primaryButton;
  final DialogButton? secondaryButton;

  /// If [customContent] is provided, it will be used instead of the [content] text.
  final Widget? customContent;

  /// If provided, the dialog's content will have this fixed height.
  /// Otherwise, it will size itself based on the content.
  final double? height;

  /// If true, the dialogs will automatically pop when either button is pressed.
  /// If false, the caller must handle popping the dialogs manually.
  /// Defaults to [true]
  final bool buttonsCanPopAutomatically;

  final DialogStatus status;
  final IconData? statusIcon;

  const MyDialog({
    super.key,
    this.title,
    this.content,
    this.primaryButton,
    this.secondaryButton,
    this.customContent,
    this.height,
    this.buttonsCanPopAutomatically = true,
    this.status = DialogStatus.standard,
    this.statusIcon,
  });

  @override
  State<MyDialog> createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
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

    IconData? defaultIcon;
    Color? iconColor;

    switch (widget.status) {
      case DialogStatus.success:
        defaultIcon = AppIcons.checkCircle;
        iconColor = context.colorScheme.primary;
        break;
      case DialogStatus.warning:
        defaultIcon = AppIcons.warning;
        iconColor = context.extendedColors.warning.color;
        break;
      case DialogStatus.danger:
        defaultIcon = AppIcons.error;
        iconColor = context.extendedColors.danger.color;
        break;
      case DialogStatus.info:
        defaultIcon = AppIcons.info;
        iconColor = context.extendedColors.info.color;
        break;
      case DialogStatus.standard:
        defaultIcon = null;
        iconColor = null;
        break;
    }

    final displayIcon = widget.statusIcon ?? defaultIcon;
    final finalIconColor = iconColor ?? context.colorScheme.primary;

    return AlertDialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: context.brL),
      titlePadding: _titlePadding(context),
      contentPadding: widget.content != null
          ? _contentPadding(context)
          : EdgeInsets.zero,
      actionsPadding: EdgeInsets.all(context.setSize(20)),
      title: (widget.title != null || displayIcon != null)
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (displayIcon != null) ...[
                  Container(
                    padding: EdgeInsets.all(context.setSize(16)),
                    decoration: BoxDecoration(
                      color: finalIconColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: MyIcon(
                      icon: displayIcon,
                      color: finalIconColor,
                      size: context.setSize(36),
                    ),
                  ),
                  SizedBox(height: context.setSize(16)),
                ],
                if (widget.title != null)
                  Text(
                    widget.title!,
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
              ],
            )
          : null,
      content: widget.content != null || widget.customContent != null
          ? SizedBox(
              width: context.screenWidth * .75,
              height: widget.height,
              child:
                  widget.customContent ??
                  Text(
                    widget.content!,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
            )
          : null,

      actions: [
        if (widget.content != null) SizedBox(height: context.spaceS),
        Column(
          spacing: context.setSize(8),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.primaryButton != null) ...[
              MyButton.primary(
                onPressed: _handlePrimaryPressed,
                height: context.setSize(48),
                text: widget.primaryButton!.text,
                prefixIcon: widget.primaryButton!.prefixIcon,
                suffixIcon: widget.primaryButton!.suffixIcon,
                timerSeconds: widget.primaryButton!.timerSeconds,
                autoLoading: widget.primaryButton!.autoLoading,
                color: finalIconColor,
              ),
            ],

            if (widget.secondaryButton != null) ...[
              MyButton.outlinedNeutral(
                onPressed: _handleSecondaryPressed,
                height: context.setSize(48),
                padding: EdgeInsets.zero,
                text: widget.secondaryButton!.text,
                prefixIcon: widget.secondaryButton!.prefixIcon,
                suffixIcon: widget.secondaryButton!.suffixIcon,
                timerSeconds: widget.secondaryButton!.timerSeconds,
                autoLoading: widget.secondaryButton!.autoLoading,
              ),
            ],
          ],
        ),
      ],
    );
  }

  EdgeInsets _titlePadding(BuildContext context) {
    final double titlePaddingVal = context.setSize(24);
    return EdgeInsets.only(
      left: titlePaddingVal,
      right: titlePaddingVal,
      top: titlePaddingVal,
      bottom: titlePaddingVal / 2,
    );
  }

  EdgeInsets _contentPadding(BuildContext context) {
    final double contentPaddingVal = context.setSize(24);
    return EdgeInsets.only(
      left: contentPaddingVal,
      right: contentPaddingVal,
      top: 0,
      bottom: contentPaddingVal / 2,
    );
  }
}
