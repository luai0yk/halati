import 'package:flutter/material.dart';
import 'package:flutter_app_template/core/constants/app_durations.dart';
import 'package:flutter_app_template/core/constants/app_icons.dart';
import 'package:flutter_app_template/core/utils/extensions/context_extension.dart';
import 'package:flutter_app_template/core/utils/extensions/responsive_size.dart';
import 'package:flutter_app_template/core/utils/extensions/responsive_values.dart';
import 'package:flutter_app_template/shared/widgets/misc/my_icon.dart';

enum ToastStatus { standard, success, warning, danger, info }

class MyToast extends StatefulWidget {
  final String message;
  final Duration duration;
  final VoidCallback onDismiss;
  final ToastStatus status;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onAction;

  const MyToast({
    super.key,
    required this.message,
    required this.duration,
    required this.onDismiss,
    this.status = ToastStatus.standard,
    this.icon,
    this.actionText,
    this.onAction,
  });

  @override
  State<MyToast> createState() => MyToastState();
}

class MyToastState extends State<MyToast> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: AppDurations.fast);

    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic, // smooth show
        reverseCurve: Curves.easeInCubic, // smooth dismiss
      ),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: const Interval(
        0.0,
        0.8, // fade out a bit faster than scale
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();

    Future.delayed(widget.duration, () async {
      if (mounted && !_isDismissed) {
        await dismiss();
      }
    });
  }

  bool _isDismissed = false;

  Future<void> dismiss() async {
    if (_isDismissed) return;
    _isDismissed = true;
    await _controller.reverse();
    if (mounted) {
      widget.onDismiss();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    IconData? defaultIcon;

    switch (widget.status) {
      case ToastStatus.success:
        bgColor = context.colorScheme.primary;
        defaultIcon = AppIcons.checkCircle;
        break;
      case ToastStatus.warning:
        bgColor = Colors.orange;
        defaultIcon = AppIcons.warning;
        break;
      case ToastStatus.danger:
        bgColor = context.extendedColors.danger.color;
        defaultIcon = AppIcons.error;
        break;
      case ToastStatus.info:
        bgColor = context.extendedColors.info.color;
        defaultIcon = AppIcons.info;
        break;
      case ToastStatus.standard:
        bgColor = const Color(0xFF323232);
        defaultIcon = null;
        break;
    }

    final displayIcon = widget.icon ?? defaultIcon;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Positioned(
      bottom: context.setSize(20) + bottomInset,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.setSize(8),
                  vertical: context.setSize(12),
                ),
                margin: EdgeInsets.symmetric(horizontal: context.spaceM),
                decoration: BoxDecoration(
                  borderRadius: context.brM,
                  color: bgColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: context.radiusS,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (displayIcon != null) ...[
                      MyIcon(
                        icon: displayIcon,
                        color: Colors.white,
                        size: context.setSize(18),
                      ),
                      SizedBox(width: context.setSize(8)),
                    ],
                    Flexible(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.setSize(14),
                          height: 1.3,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    if (widget.actionText != null &&
                        widget.onAction != null) ...[
                      SizedBox(width: context.setSize(8)),
                      Material(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: context.brCircular,
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: widget.onAction,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.setSize(8),
                              vertical: context.setSize(4),
                            ),
                            child: Text(
                              widget.actionText!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: context.setSize(12),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
