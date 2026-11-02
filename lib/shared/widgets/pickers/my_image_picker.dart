import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_template/core/l10n/app_localizations.dart';
import 'package:flutter_app_template/core/constants/app_icons.dart';
import 'package:flutter_app_template/core/utils/extensions/context_extension.dart';
import 'package:flutter_app_template/core/utils/extensions/responsive_size.dart';
import 'package:flutter_app_template/core/utils/extensions/responsive_values.dart';
import 'package:flutter_app_template/core/utils/helpers/ui/bottom_sheet_helper.dart';
import 'package:flutter_app_template/core/utils/helpers/ui/dialog_helper.dart';
import 'package:flutter_app_template/core/utils/helpers/ui/toast_helper.dart';
import 'package:flutter_app_template/core/utils/validators/empty_validator.dart';
import 'package:flutter_app_template/shared/controller/image_picker_controller.dart';
import 'package:flutter_app_template/shared/widgets/buttons/my_button.dart';
import 'package:flutter_app_template/shared/widgets/cards/my_card.dart';
import 'package:flutter_app_template/shared/widgets/dialogs/my_dialog.dart';
import 'package:flutter_app_template/shared/widgets/images/my_image.dart';
import 'package:flutter_app_template/shared/widgets/misc/my_icon.dart';
import 'package:flutter_app_template/shared/widgets/sheets/my_bottom_sheet.dart';

class MyImagePicker extends StatelessWidget {
  final ImagePickerController controller;
  final double? width;
  final double? height;
  final IconData pickIcon;
  final double? iconSize;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final double? borderWidth;
  final Color? borderColor;
  final Function(File?)? onChanged;
  final bool isRequired;
  final String? requiredMessage;
  final FormFieldValidator<File>? validator;
  final String? label;

  const MyImagePicker({
    super.key,
    required this.controller,
    this.width,
    this.height,
    this.pickIcon = AppIcons.addPhoto,
    this.iconSize,
    this.backgroundColor,
    this.onChanged,
    this.borderRadius,
    this.padding,
    this.borderWidth,
    this.borderColor,
    this.isRequired = false,
    this.requiredMessage,
    this.validator,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<File>(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      initialValue: controller.pickedImage,
      validator: (value) {
        if (isRequired) {
          final emptyError = EmptyValidator.validate(
            context.l10n,
            value?.path ?? '',
            msg: requiredMessage,
          );
          if (emptyError != null) return emptyError;
        }
        if (validator != null) {
          return validator!(value);
        }
        return null;
      },
      builder: (FormFieldState<File> state) {
        return ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final ctr = controller;
            if (state.value != ctr.pickedImage) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (state.mounted) {
                  state.didChange(ctr.pickedImage);
                }
              });
            }

            final double displayWidth = width ?? context.setSize(120);
            final double displayHeight = height ?? context.setSize(120);

            final bool hasError = state.hasError;
            final Color? resolvedBorderColor = hasError
                ? context.extendedColors.danger.color
                : borderColor;
            final double? resolvedBorderWidth = hasError
                ? context.setSize(1.5)
                : borderWidth;

            Widget content;
            if (ctr.hasImage) {
              content = SizedBox(
                width: displayWidth,
                height: displayHeight,
                child: Stack(
                  children: [
                    MyImage.file(
                      file: ctr.pickedImage!,
                      width: displayWidth,
                      height: displayHeight,
                      padding: padding,
                      borderRadius: borderRadius,
                      backgroundColor: backgroundColor,
                      borderColor: resolvedBorderColor,
                      borderWidth: resolvedBorderWidth,
                      isViewable: true,
                    ),

                    // Action buttons (Edit and Delete)
                    Positioned.directional(
                      textDirection: Directionality.of(context),
                      bottom: context.spaceXs,
                      end: context.spaceXs,
                      child: Row(
                        spacing: context.spaceXs,
                        children: [
                          _ActionButton(
                            icon: AppIcons.edit,
                            onTap: () => _showPickOptions(context, state),
                          ),
                          _ActionButton(
                            icon: AppIcons.delete,
                            backgroundColor:
                                context.extendedColors.danger.color,
                            iconColor: Colors.white,
                            onTap: () {
                              ctr.removeImage();
                              state.didChange(null);
                              onChanged?.call(null);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // If no image is selected, show the empty state pick icon
              content = MyCard.outlined(
                onTap: () => _showPickOptions(context, state),
                width: displayWidth,
                height: displayHeight,
                padding: padding ?? EdgeInsets.zero,
                borderRadius: borderRadius ?? context.brS,
                color: backgroundColor ?? context.colorScheme.surfaceContainer,
                borderColor: resolvedBorderColor,
                borderWidth: resolvedBorderWidth,
                child: Center(
                  child: MyIcon(
                    icon: pickIcon,
                    size: iconSize ?? context.setSize(40),
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                content,
                if (label != null || hasError) ...[
                  SizedBox(height: context.spaceXs),
                  Text(
                    hasError ? state.errorText! : label!,
                    textAlign: TextAlign.center,
                    style:
                        (hasError
                                ? context.textTheme.bodySmall
                                : context.textTheme.bodyMedium)
                            ?.copyWith(
                              color: hasError
                                  ? context.extendedColors.danger.color
                                  : context.colorScheme.onSurfaceVariant,
                            ),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showPickOptions(
    BuildContext context,
    FormFieldState<File> state,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final double recentImageSize = context.setSize(100);

    await BottomSheetHelper.show(
      child: MyBottomSheet(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final ctr = controller;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Options for picking image from Gallery, File, or Camera
                Row(
                  spacing: context.spaceM,
                  children: [
                    _BottomSheetOption(
                      icon: AppIcons.gallery,
                      title: l10n.gallery,
                      onTap: () async {
                        Navigator.of(context).pop();

                        await controller.pickFromGallery();
                        state.didChange(controller.pickedImage);
                        onChanged?.call(controller.pickedImage);
                      },
                    ),
                    _BottomSheetOption(
                      icon: AppIcons.file,
                      title: l10n.file,
                      onTap: () async {
                        Navigator.of(context).pop();

                        await controller.pickFromFile();
                        state.didChange(controller.pickedImage);
                        onChanged?.call(controller.pickedImage);
                      },
                    ),
                    _BottomSheetOption(
                      icon: AppIcons.camera,
                      title: l10n.camera,
                      onTap: () async {
                        Navigator.of(context).pop();

                        await controller.pickFromCamera();
                        state.didChange(controller.pickedImage);
                        onChanged?.call(controller.pickedImage);
                      },
                    ),
                  ],
                ),

                SizedBox(height: context.spaceM),

                if (ctr.recentImages.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.recentImages,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colorScheme.onSurface,
                        ),
                      ),

                      MyButton.text(
                        text: l10n.clearAll,
                        height: context.setSize(30),
                        borderRadius: context.brS,
                        color: context.extendedColors.danger.color,
                        onPressed: () => _showClearAllDialog(context, state),
                      ),
                    ],
                  ),

                SizedBox(height: context.spaceS),

                if (ctr.recentImages.isEmpty)
                  SizedBox(
                    height: recentImageSize,
                    child: Center(
                      child: Text(
                        l10n.noRecentImages,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: recentImageSize,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: ctr.recentImages.length,
                      separatorBuilder: (_, _) =>
                          SizedBox(width: context.spaceS),
                      itemBuilder: (_, index) {
                        final image = ctr.recentImages[index];

                        return MyCard.filled(
                          padding: EdgeInsets.zero,
                          onTap: () async {
                            await ctr.selectRecentImage(image);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                            state.didChange(ctr.pickedImage);
                            onChanged?.call(ctr.pickedImage);
                          },
                          onLongPress: () async {
                            await ctr.removeRecentImage(image);
                            ToastHelper.show(msg: l10n.deletedFromRecent);
                            state.didChange(ctr.pickedImage);
                            onChanged?.call(ctr.pickedImage);
                          },
                          child: MyImage.file(
                            file: image,
                            width: recentImageSize,
                            height: recentImageSize,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, FormFieldState<File> state) {
    final l10n = AppLocalizations.of(context)!;

    DialogHelper.show(
      child: MyDialog(
        title: l10n.clearRecentImagesTitle,
        content: l10n.clearAllMessage,
        status: DialogStatus.danger,
        statusIcon: AppIcons.clear,
        primaryButton: DialogButton(
          text: l10n.clear,
          onPressed: () async {
            await controller.clearRecentImages();
            state.didChange(controller.pickedImage);
            onChanged?.call(controller.pickedImage);
          },
        ),
        secondaryButton: DialogButton(text: l10n.cancel),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return MyCard.elevated(
      padding: context.insetsAllXs,
      borderRadius: context.brS,
      color: backgroundColor,
      onTap: onTap,
      child: MyIcon(icon: icon, color: iconColor, size: context.iconM),
    );
  }
}

class _BottomSheetOption extends StatelessWidget {
  const _BottomSheetOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MyCard.filled(
        onTap: onTap,
        child: Column(
          spacing: context.setSize(12),
          children: [
            MyIcon(icon: icon, size: context.setSize(30)),
            Text(
              title,
              style: context.textTheme.labelMedium?.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
