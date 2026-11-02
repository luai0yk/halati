import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:status_saver/core/constants/app_durations.dart';
import 'package:status_saver/core/l10n/app_localizations.dart';
import 'package:status_saver/core/services/cash/cash_keys.dart';
import 'package:status_saver/core/services/cash/cash_service.dart';
import 'package:status_saver/core/utils/extensions/context_extension.dart';
import 'package:status_saver/core/utils/extensions/responsive_size.dart';
import 'package:status_saver/core/utils/helpers/ui/bottom_sheet_helper.dart';
import 'package:status_saver/core/utils/helpers/ui/toast_helper.dart';
import 'package:status_saver/shared/widgets/cards/my_card.dart';
import 'package:status_saver/shared/widgets/input/my_text_field.dart';
import 'package:status_saver/shared/widgets/misc/my_toast.dart';
import 'package:status_saver/shared/widgets/sheets/my_bottom_sheet.dart';
import 'package:get/get.dart';

class MyColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color>? onColorChanged;
  final bool showRgb;

  const MyColorPicker({
    super.key,
    required this.initialColor,
    this.onColorChanged,
    this.showRgb = false,
  });

  static Future<Color?> show({
    required BuildContext context,
    Color? initialColor,
    String? title,
    bool showRgb = false,
    ValueChanged<Color>? onColorChanged,
  }) {
    final l10n = AppLocalizations.of(context)!;
    Color currentSelectedColor = initialColor ?? Colors.blue;
    final pickerKey = GlobalKey<_MyColorPickerState>();

    return BottomSheetHelper.show<Color>(
      child: MyBottomSheet(
        title: title ?? l10n.selectColor,
        buttonsCanPopAutomatically: false,
        primaryButton: SheetButton(
          text: l10n.ok,
          onPressed: () {
            if (pickerKey.currentState?.isValid == false) {
              ToastHelper.show(
                msg: l10n.invalidFormat,
                status: ToastStatus.danger,
              );
              return;
            }
            // Save to recent colors
            _saveColorToRecents(currentSelectedColor);
            onColorChanged?.call(currentSelectedColor);
            BottomSheetHelper.dismiss(result: currentSelectedColor);
          },
        ),
        secondaryButton: SheetButton(
          text: l10n.cancel,
          onPressed: () {
            BottomSheetHelper.dismiss();
          },
        ),
        child: MyColorPicker(
          key: pickerKey,
          initialColor: currentSelectedColor,
          showRgb: showRgb,
          onColorChanged: (color) {
            currentSelectedColor = color;
          },
        ),
      ),
    );
  }

  static void _saveColorToRecents(Color color) {
    final cashService = Get.find<CashService>();
    final colorsStrList =
        cashService.getStringList(CashKeys.recentColors) ?? [];

    // Parse current list
    List<Color> recentColors = colorsStrList
        .map((e) {
          String hex = e.replaceAll('#', '');
          if (hex.length == 3) {
            hex = 'FF${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}';
          }
          if (hex.length == 6) hex = 'FF$hex';
          final int? value = int.tryParse(hex, radix: 16);
          return value != null ? Color(value) : null;
        })
        .whereType<Color>()
        .toList();

    // Remove duplicates
    recentColors.removeWhere((c) => c.toARGB32() == color.toARGB32());
    recentColors.insert(0, color);
    if (recentColors.length > 12) {
      recentColors = recentColors.sublist(0, 12);
    }

    final List<String> newColorsStr = recentColors.map((c) {
      final int a = (c.a * 255.0).round().clamp(0, 255);
      final int r = (c.r * 255.0).round().clamp(0, 255);
      final int g = (c.g * 255.0).round().clamp(0, 255);
      final int b = (c.b * 255.0).round().clamp(0, 255);
      return '${a.toRadixString(16).padLeft(2, '0')}'
              '${r.toRadixString(16).padLeft(2, '0')}'
              '${g.toRadixString(16).padLeft(2, '0')}'
              '${b.toRadixString(16).padLeft(2, '0')}'
          .toUpperCase();
    }).toList();

    cashService.setStringList(CashKeys.recentColors, newColorsStr);
  }

  @override
  State<MyColorPicker> createState() => _MyColorPickerState();
}

class _MyColorPickerState extends State<MyColorPicker> {
  late final ValueNotifier<HSVColor> _hsvColorNotifier;
  final TextEditingController _hexController = TextEditingController();
  final CashService _cashService = Get.find<CashService>();

  List<Color> _recentColors = [];

  final _hexRegex = RegExp(r'^([0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');

  bool get isValid => _hexRegex.hasMatch(_hexController.text);

  @override
  void initState() {
    super.initState();
    _hsvColorNotifier = ValueNotifier(HSVColor.fromColor(widget.initialColor));
    _updateHexController();
    _loadRecentColors();
  }

  @override
  void dispose() {
    _hexController.dispose();
    _hsvColorNotifier.dispose();
    super.dispose();
  }

  void _loadRecentColors() {
    final List<String>? colorsStr = _cashService.getStringList(
      CashKeys.recentColors,
    );
    if (colorsStr != null) {
      setState(() {
        _recentColors = colorsStr
            .map((e) => _colorFromHex(e))
            .whereType<Color>()
            .toList();
      });
    }
  }

  String _colorToHex(Color color) {
    final int a = (color.a * 255.0).round().clamp(0, 255);
    final int r = (color.r * 255.0).round().clamp(0, 255);
    final int g = (color.g * 255.0).round().clamp(0, 255);
    final int b = (color.b * 255.0).round().clamp(0, 255);

    return '${a.toRadixString(16).padLeft(2, '0')}'
            '${r.toRadixString(16).padLeft(2, '0')}'
            '${g.toRadixString(16).padLeft(2, '0')}'
            '${b.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  Color? _colorFromHex(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 3) {
      hex = 'FF${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}';
    } else if (hex.length == 6) {
      hex = 'FF$hex';
    } else if (hex.length != 8) {
      return null;
    }

    final int? value = int.tryParse(hex, radix: 16);
    if (value == null) return null;
    return Color(value);
  }

  void _updateHexController() {
    final String hex = _colorToHex(_hsvColorNotifier.value.toColor());
    if (_hexController.text.toUpperCase() != hex) {
      _hexController.text = hex;
    }
  }

  void _onColorChanged(HSVColor color) {
    _hsvColorNotifier.value = color;
    _updateHexController();
    widget.onColorChanged?.call(color.toColor());
  }

  void _onHexSubmitted(String value) {
    final cleanValue = value.trim();
    if (_hexRegex.hasMatch(cleanValue)) {
      final Color? color = _colorFromHex(cleanValue);
      if (color != null) {
        _hsvColorNotifier.value = HSVColor.fromColor(color);
        widget.onColorChanged?.call(color);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSVArea(context),
          SizedBox(height: context.setSize(16)),
          _buildHueSlider(context),
          SizedBox(height: context.setSize(24)),
          _buildColorPreviewAndInput(context),
          SizedBox(height: context.setSize(24)),
          _buildRecentColors(context),
          SizedBox(height: context.setSize(8)),
        ],
      ),
    );
  }

  Widget _buildSVArea(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = context.setSize(200.0);

        return Semantics(
          label: 'Color saturation and brightness',
          slider: true,
          value:
              '${(_hsvColorNotifier.value.saturation * 100).round()}% saturation, ${(_hsvColorNotifier.value.value * 100).round()}% brightness',
          child: GestureDetector(
            onPanUpdate: (details) {
              final double x = details.localPosition.dx.clamp(0.0, width);
              final double y = details.localPosition.dy.clamp(0.0, height);
              _onColorChanged(
                _hsvColorNotifier.value
                    .withSaturation(x / width)
                    .withValue(1.0 - (y / height)),
              );
            },
            onPanDown: (details) {
              final double x = details.localPosition.dx.clamp(0.0, width);
              final double y = details.localPosition.dy.clamp(0.0, height);
              _onColorChanged(
                _hsvColorNotifier.value
                    .withSaturation(x / width)
                    .withValue(1.0 - (y / height)),
              );
            },
            child: MyCard.bordered(
              width: width,
              height: height,
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(context.setSize(12)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.setSize(12)),
                child: Stack(
                  children: [
                    ValueListenableBuilder<HSVColor>(
                      valueListenable: _hsvColorNotifier,
                      builder: (context, hsv, child) {
                        return Container(
                          color: HSVColor.fromAHSV(
                            1.0,
                            hsv.hue,
                            1.0,
                            1.0,
                          ).toColor(),
                        );
                      },
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.transparent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    ValueListenableBuilder<HSVColor>(
                      valueListenable: _hsvColorNotifier,
                      builder: (context, hsv, child) {
                        return Positioned(
                          left: hsv.saturation * width - context.setSize(12),
                          top: (1.0 - hsv.value) * height - context.setSize(12),
                          child: Container(
                            width: context.setSize(24),
                            height: context.setSize(24),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: hsv.toColor(),
                              border: Border.all(
                                color: Colors.white,
                                width: context.setSize(2.0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: context.setSize(4),
                                  spreadRadius: context.setSize(1),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHueSlider(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = context.setSize(30.0);

        return Semantics(
          label: 'Color hue',
          slider: true,
          value: '${_hsvColorNotifier.value.hue.round()} degrees',
          child: GestureDetector(
            onPanUpdate: (details) {
              final double x = details.localPosition.dx.clamp(0.0, width);
              _onColorChanged(
                _hsvColorNotifier.value.withHue((x / width) * 360),
              );
            },
            onPanDown: (details) {
              final double x = details.localPosition.dx.clamp(0.0, width);
              _onColorChanged(
                _hsvColorNotifier.value.withHue((x / width) * 360),
              );
            },
            child: MyCard.bordered(
              width: width,
              height: height,
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(height / 2),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 255, 0, 0),
                      Color.fromARGB(255, 255, 255, 0),
                      Color.fromARGB(255, 0, 255, 0),
                      Color.fromARGB(255, 0, 255, 255),
                      Color.fromARGB(255, 0, 0, 255),
                      Color.fromARGB(255, 255, 0, 255),
                      Color.fromARGB(255, 255, 0, 0),
                    ],
                    stops: [0.0, 0.166, 0.333, 0.5, 0.666, 0.833, 1.0],
                  ),
                ),
                child: Stack(
                  children: [
                    ValueListenableBuilder<HSVColor>(
                      valueListenable: _hsvColorNotifier,
                      builder: (context, hsv, child) {
                        return Positioned(
                          left: (hsv.hue / 360) * width - (height / 2),
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: height,
                            height: height,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: context.setSize(4),
                                  spreadRadius: context.setSize(1),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorPreviewAndInput(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Color Preview (Bigger, Rounded Rectangle)
        ValueListenableBuilder<HSVColor>(
          valueListenable: _hsvColorNotifier,
          builder: (context, hsv, child) {
            return MyCard.bordered(
              width: context.setSize(100),
              height: context.setSize(56),
              padding: EdgeInsets.zero,
              color: hsv.toColor(),
              child: const SizedBox.shrink(),
            );
          },
        ),
        SizedBox(width: context.setSize(16)),
        // Hex & RGB Text Fields
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyTextField(
                controller: _hexController,
                hintText: 'FFF000',
                labelText: l10n.customColor,
                prefix: const Text('# '),
                onChanged: _onHexSubmitted,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
                ],
                validator: (value) {
                  final cleanValue = value?.trim();
                  if (cleanValue == null || cleanValue.isEmpty) {
                    return l10n.required;
                  }
                  if (!_hexRegex.hasMatch(cleanValue)) {
                    return l10n.invalidFormat;
                  }
                  return null;
                },
              ),
              if (widget.showRgb) ...[
                SizedBox(height: context.setSize(8)),
                ValueListenableBuilder<HSVColor>(
                  valueListenable: _hsvColorNotifier,
                  builder: (context, hsv, child) {
                    final color = hsv.toColor();
                    final int r = (color.r * 255.0).round().clamp(0, 255);
                    final int g = (color.g * 255.0).round().clamp(0, 255);
                    final int b = (color.b * 255.0).round().clamp(0, 255);
                    return SelectableText(
                      'RGB($r, $g, $b)',
                      style: TextStyle(
                        fontSize: context.setSize(13),
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentColors(BuildContext context) {
    if (_recentColors.isEmpty) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recentColors,
          style: TextStyle(
            color: context.colorScheme.onSurface,
            fontSize: context.setSize(12),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: context.setSize(12)),
        ValueListenableBuilder<HSVColor>(
          valueListenable: _hsvColorNotifier,
          builder: (context, hsv, child) {
            return Wrap(
              spacing: context.setSize(12),
              runSpacing: context.setSize(12),
              children: _recentColors.map((color) {
                final bool isSelected =
                    color.toARGB32() == hsv.toColor().toARGB32();
                return GestureDetector(
                  onTap: () {
                    _hsvColorNotifier.value = HSVColor.fromColor(color);
                    _updateHexController();
                    widget.onColorChanged?.call(color);
                  },
                  child: AnimatedContainer(
                    duration: AppDurations.fast,
                    width: context.setSize(40),
                    height: context.setSize(40),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      border: Border.all(
                        color: isSelected
                            ? context.colorScheme.primary
                            : context.colorScheme.outlineVariant,
                        width: context.setSize(isSelected ? 3.0 : 1.0),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
