import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:status_saver/core/constants/app_icons.dart';
import 'package:status_saver/core/utils/extensions/context_extension.dart';
import 'package:status_saver/core/utils/extensions/responsive_size.dart';
import 'package:status_saver/core/utils/extensions/responsive_values.dart';
import 'package:status_saver/core/utils/validators/empty_validator.dart';
import 'package:status_saver/shared/widgets/animations/my_animated_scale_fade_switcher.dart';
import 'package:status_saver/shared/widgets/buttons/my_icon_button.dart';
import 'package:status_saver/shared/widgets/misc/my_icon.dart';

enum _MyTextFieldType { standard, plain }

class MyTextField extends StatelessWidget {
  final _MyTextFieldType _type;

  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final bool isRequired;
  final String? requiredMessage;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? prefixWidget;
  final Widget? suffixWidget;
  final Widget? prefix;
  final Widget? suffix;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final ValueChanged<String>? onChanged;
  final GestureTapCallback? onTap;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? style;
  final TextAlign textAlign;
  final bool isSearch;
  final BorderRadius? borderRadius;
  final Key? fieldKey;
  final bool? showCursor;
  final bool autofocus;
  final TextDirection? textDirection;

  const MyTextField({
    super.key,
    // ignore: library_private_types_in_public_api
    _MyTextFieldType type = _MyTextFieldType.standard,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.isRequired = false,
    this.requiredMessage,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixWidget,
    this.suffixWidget,
    this.prefix,
    this.suffix,
    this.fillColor,
    this.contentPadding,
    this.onChanged,
    this.onTap,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onSaved,
    this.validator,
    this.inputFormatters,
    this.style,
    this.textAlign = TextAlign.start,
    this.isSearch = false,
    this.borderRadius,
    this.fieldKey,
    this.showCursor,
    this.autofocus = false,
    this.textDirection,
  }) : _type = type;

  /// Creates a minimal text field with no borders and transparent background by default.
  /// Ideal for search bars, inline editing, or highly customized wrappers.
  factory MyTextField.plain({
    Key? key,
    TextEditingController? controller,
    String? initialValue,
    FocusNode? focusNode,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int? maxLines = 1,
    int? minLines,
    int? maxLength,
    bool enabled = true,
    bool readOnly = false,
    bool isRequired = false,
    String? requiredMessage,
    String? hintText,
    String? labelText,
    IconData? prefixIcon,
    IconData? suffixIcon,
    Widget? prefixWidget,
    Widget? suffixWidget,
    Widget? prefix,
    Widget? suffix,
    Color? fillColor,
    EdgeInsetsGeometry? contentPadding = EdgeInsets.zero,
    ValueChanged<String>? onChanged,
    GestureTapCallback? onTap,
    VoidCallback? onEditingComplete,
    ValueChanged<String>? onFieldSubmitted,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    List<TextInputFormatter>? inputFormatters,
    TextStyle? style,
    TextAlign textAlign = TextAlign.start,
    bool isSearch = false,
    Key? fieldKey,
    bool? showCursor,
    bool autofocus = false,
    TextDirection? textDirection,
  }) {
    return MyTextField(
      key: key,
      type: _MyTextFieldType.plain,
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      enabled: enabled,
      readOnly: readOnly,
      isRequired: isRequired,
      requiredMessage: requiredMessage,
      hintText: hintText,
      labelText: labelText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      prefixWidget: prefixWidget,
      suffixWidget: suffixWidget,
      prefix: prefix,
      suffix: suffix,
      fillColor: fillColor,
      contentPadding: contentPadding,
      onChanged: onChanged,
      onTap: onTap,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      onSaved: onSaved,
      validator: validator,
      inputFormatters: inputFormatters,
      style: style,
      textAlign: textAlign,
      isSearch: isSearch,
      fieldKey: fieldKey,
      showCursor: showCursor,
      autofocus: autofocus,
      textDirection: textDirection,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _TextFieldWrapper(
      initialObscureText: obscureText,
      controller: controller,
      initialValue: initialValue,
      builder:
          (
            context,
            currentObscureText,
            setObscureText,
            effectiveController,
            hasText,
          ) {
            final ColorScheme colors = context.colorScheme;

            final BorderRadius resolvedRadius =
                borderRadius ?? BorderRadius.circular(context.radiusM);

            // Resolve border styles based on variant
            final InputBorder baseBorder = _type == _MyTextFieldType.standard
                ? OutlineInputBorder(
                    borderRadius: resolvedRadius,
                    borderSide: isSearch
                        ? BorderSide.none
                        : BorderSide(
                            color: colors.outlineVariant,
                            width: context.setSize(1),
                          ),
                  )
                : InputBorder.none;

            final InputBorder focusedBorder = _type == _MyTextFieldType.standard
                ? OutlineInputBorder(
                    borderRadius: resolvedRadius,
                    borderSide: isSearch
                        ? BorderSide.none
                        : BorderSide(
                            color: context.colorScheme.primary,
                            width: context.setSize(1.5),
                          ),
                  )
                : InputBorder.none;

            final InputBorder errorBorder = _type == _MyTextFieldType.standard
                ? OutlineInputBorder(
                    borderRadius: resolvedRadius,
                    borderSide: isSearch
                        ? BorderSide.none
                        : BorderSide(
                            color: context.extendedColors.danger.color,
                            width: context.setSize(1),
                          ),
                  )
                : InputBorder.none;

            // Resolve background color
            Color? resolvedFillColor;
            if (fillColor != null) {
              resolvedFillColor = fillColor;
            } else if (_type == _MyTextFieldType.standard) {
              resolvedFillColor = colors.surfaceContainer;
            } else {
              resolvedFillColor = Colors.transparent;
            }

            return TextFormField(
              key: fieldKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: effectiveController,
              initialValue: null,
              cursorRadius: Radius.circular(context.radiusS),
              cursorColor: colors.primary.withValues(alpha: 0.5),
              cursorErrorColor: colors.error.withValues(alpha: 0.5),
              cursorWidth: context.setSize(2),
              cursorOpacityAnimates: true,
              showCursor: showCursor,
              autofocus: autofocus,
              textDirection: textDirection,
              focusNode: focusNode,
              keyboardType: keyboardType,
              textInputAction:
                  textInputAction ?? (isSearch ? TextInputAction.search : null),
              obscureText: currentObscureText,
              textCapitalization: textCapitalization,
              maxLines: currentObscureText ? 1 : maxLines,
              minLines: minLines,
              maxLength: maxLength,
              enabled: enabled,
              readOnly: readOnly,
              onChanged: onChanged,
              onTap: onTap,
              onEditingComplete: onEditingComplete,
              onFieldSubmitted: onFieldSubmitted,
              onSaved: onSaved,
              validator: (value) {
                if (isRequired) {
                  final emptyError = EmptyValidator.validate(
                    context.l10n,
                    value,
                    msg: requiredMessage,
                  );
                  if (emptyError != null) return emptyError;
                }
                if (validator != null) {
                  return validator!(value);
                }
                return null;
              },
              inputFormatters: inputFormatters,
              style:
                  style ??
                  context.textTheme.bodyLarge?.copyWith(
                    color: colors.onSurface,
                  ),
              textAlign: textAlign,
              decoration: InputDecoration(
                filled: true,
                fillColor: resolvedFillColor,
                hintText: hintText,
                counterText:
                    '', // Hides the character counter when maxLength is set
                hintStyle: context.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                label: _buildLabel(context),
                prefixIcon:
                    prefixWidget ??
                    (prefixIcon != null
                        ? MyIcon(
                            icon: prefixIcon!,
                            color: colors.onSurfaceVariant,
                          )
                        : (isSearch
                              ? MyIcon(
                                  icon: AppIcons.search,
                                  color: colors.onSurfaceVariant,
                                )
                              : null)),
                suffixIcon: obscureText
                    ? MyAnimatedScaleFadeSwitcher(
                        child: MyIconButton.ghost(
                          key: ValueKey(currentObscureText),
                          icon: currentObscureText
                              ? AppIcons.eyeSlash
                              : AppIcons.eye,
                          onPressed: () => setObscureText(!currentObscureText),
                        ),
                      )
                    : (isSearch
                          ? MyAnimatedScaleFadeSwitcher(
                              child: hasText
                                  ? MyIconButton.ghost(
                                      key: const ValueKey('clear_btn'),
                                      tooltip: context.l10n.clear,
                                      icon: AppIcons.close,
                                      onPressed: () {
                                        effectiveController.clear();
                                        onChanged?.call('');
                                      },
                                    )
                                  : (suffixWidget != null
                                        ? KeyedSubtree(
                                            key: const ValueKey(
                                              'suffix_widget',
                                            ),
                                            child: suffixWidget!,
                                          )
                                        : (suffixIcon != null
                                              ? MyIcon(
                                                  key: const ValueKey(
                                                    'suffix_icon',
                                                  ),
                                                  icon: suffixIcon!,
                                                  color:
                                                      colors.onSurfaceVariant,
                                                )
                                              : const SizedBox.shrink(
                                                  key: ValueKey('empty'),
                                                ))),
                            )
                          : (suffixWidget ??
                                (suffixIcon != null
                                    ? MyIcon(
                                        icon: suffixIcon!,
                                        color: colors.onSurfaceVariant,
                                      )
                                    : null))),
                prefix: prefix,
                suffix: suffix,
                contentPadding:
                    contentPadding ??
                    (_type == _MyTextFieldType.standard
                        ? EdgeInsets.symmetric(
                            horizontal: context.spaceM,
                            vertical: isSearch
                                ? context.spaceS
                                : context.spaceL,
                          )
                        : EdgeInsets.zero),
                border: baseBorder,
                enabledBorder: baseBorder,
                focusedBorder: focusedBorder,
                errorBorder: errorBorder,
                disabledBorder: baseBorder,
                focusedErrorBorder: errorBorder,
              ),
            );
          },
    );
  }

  /// Builds the label widget, appending a red asterisk if [isRequired] is true.
  Widget? _buildLabel(BuildContext context) {
    if (labelText == null) return null;

    if (!isRequired) {
      return Text(
        labelText!,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      );
    }

    // Use RichText to color the asterisk red independently of the label text
    return RichText(
      text: TextSpan(
        text: labelText,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
        children: [
          TextSpan(
            text: ' *',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.extendedColors.danger.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TextFieldWrapper extends StatefulWidget {
  final bool initialObscureText;
  final TextEditingController? controller;
  final String? initialValue;
  final Widget Function(
    BuildContext context,
    bool obscureText,
    void Function(bool) setObscureText,
    TextEditingController effectiveController,
    bool hasText,
  )
  builder;

  const _TextFieldWrapper({
    required this.initialObscureText,
    this.controller,
    this.initialValue,
    required this.builder,
  });

  @override
  State<_TextFieldWrapper> createState() => _TextFieldWrapperState();
}

class _TextFieldWrapperState extends State<_TextFieldWrapper> {
  late bool _obscureText;
  late TextEditingController _controller;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.initialObscureText;
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController(text: widget.initialValue);
      _isInternalController = true;
    }
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(_TextFieldWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialObscureText != widget.initialObscureText) {
      _obscureText = widget.initialObscureText;
    }
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_onTextChanged);
      if (_isInternalController) {
        _controller.dispose();
        _isInternalController = false;
      }
      if (widget.controller != null) {
        _controller = widget.controller!;
      } else {
        _controller = TextEditingController(text: widget.initialValue);
        _isInternalController = true;
      }
      _controller.addListener(_onTextChanged);
    }
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _obscureText,
      (val) => setState(() => _obscureText = val),
      _controller,
      _controller.text.isNotEmpty,
    );
  }
}
