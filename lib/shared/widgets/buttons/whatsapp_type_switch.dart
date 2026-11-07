import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:halati/core/constants/app_durations.dart';
import 'package:halati/core/enums/whatsapp_type.dart';
import 'package:halati/core/utils/extensions/context_extension.dart';
import 'package:halati/core/utils/extensions/responsive_size.dart';
import 'package:halati/core/utils/extensions/responsive_values.dart';

class WhatsAppTypeSwitch extends StatefulWidget {
  final WhatsAppType currentType;
  final ValueChanged<WhatsAppType> onChanged;

  const WhatsAppTypeSwitch({
    super.key,
    required this.currentType,
    required this.onChanged,
  });

  @override
  State<WhatsAppTypeSwitch> createState() => _WhatsAppTypeSwitchState();
}

class _WhatsAppTypeSwitchState extends State<WhatsAppTypeSwitch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.fast,
      value: widget.currentType.isBusiness ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(WhatsAppTypeSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentType != oldWidget.currentType) {
      final target = widget.currentType.isBusiness ? 1.0 : 0.0;
      if (_controller.value != target) {
        if (widget.currentType.isBusiness) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, double travelWidth) {
    if (travelWidth <= 0) return;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    double delta = details.primaryDelta! / travelWidth;
    if (isRtl) {
      delta = -delta;
    }
    _controller.value = (_controller.value + delta).clamp(0.0, 1.0);
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final shouldBeBusiness = _controller.value >= 0.5;
    final targetType = shouldBeBusiness
        ? WhatsAppType.business
        : WhatsAppType.whatsapp;

    if (shouldBeBusiness) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    if (targetType != widget.currentType) {
      HapticFeedback.selectionClick();
      widget.onChanged(targetType);
    }
  }

  void _onSelect(WhatsAppType type) {
    if (type != widget.currentType) {
      HapticFeedback.selectionClick();
      if (type.isBusiness) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      widget.onChanged(type);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final height = context.setSize(30);
    final borderRadius = BorderRadius.circular(height / 2);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final innerPadding = context.setSize(2);
        final usableWidth = totalWidth - (innerPadding * 2);
        final itemWidth = usableWidth / 2;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (details) =>
              _onHorizontalDragUpdate(details, itemWidth),
          onHorizontalDragEnd: _onHorizontalDragEnd,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: borderRadius,
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.35),
                width: context.setSize(0.75),
              ),
            ),
            padding: EdgeInsets.all(innerPadding),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final animValue = _controller.value;
                final alignmentX = -1.0 + (animValue * 2.0);

                final activeColor = colors.onPrimary;
                final inactiveColor = colors.onSurfaceVariant;

                final whatsappTextColor = Color.lerp(
                  activeColor,
                  inactiveColor,
                  animValue,
                )!;
                final businessTextColor = Color.lerp(
                  inactiveColor,
                  activeColor,
                  animValue,
                )!;

                return Stack(
                  children: [
                    Align(
                      alignment: AlignmentDirectional(alignmentX, 0.0),
                      child: Container(
                        width: itemWidth,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular((height - 4) / 2),
                          boxShadow: [
                            BoxShadow(
                              color: colors.primary.withValues(alpha: 0.25),
                              blurRadius: context.setSize(3),
                              offset: Offset(0, context.setSize(1)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _onSelect(WhatsAppType.whatsapp),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.spaceXs,
                                ),
                                child: Text(
                                  context.l10n.whatsapp,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: context.setSize(11.5),
                                    fontWeight: animValue < 0.5
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    color: whatsappTextColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _onSelect(WhatsAppType.business),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.spaceXs,
                                ),
                                child: Text(
                                  context.l10n.business,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: context.setSize(11.5),
                                    fontWeight: animValue >= 0.5
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    color: businessTextColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
