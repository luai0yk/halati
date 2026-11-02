import 'package:flutter/material.dart';
import 'package:flutter_app_template/core/constants/app_icons.dart';
import 'package:flutter_app_template/core/utils/extensions/context_extension.dart';
import 'package:flutter_app_template/core/utils/extensions/responsive_size.dart';
import 'package:flutter_app_template/core/utils/extensions/responsive_values.dart';
import 'package:flutter_app_template/shared/widgets/misc/my_icon.dart';

/// Defines a single step in [MyStepper].
class MyStep {
  final IconData icon;
  final String title;
  final String? subtitle;

  const MyStep({required this.icon, required this.title, this.subtitle});
}

/// A standalone, animated horizontal stepper without third-party dependencies.
class MyStepper extends StatelessWidget {
  final int activeStep;
  final int? maxReachedStep;
  final ValueChanged<int>? onStepReached;
  final List<MyStep> steps;
  final Duration animationDuration;
  final double? stepRadius;

  const MyStepper({
    super.key,
    required this.activeStep,
    this.maxReachedStep,
    this.onStepReached,
    required this.steps,
    this.animationDuration = const Duration(milliseconds: 320),
    this.stepRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) return const SizedBox.shrink();

    final maxStep = maxReachedStep ?? activeStep;
    final circleSize = stepRadius ?? context.setSize(34);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.spaceM,
        vertical: context.spaceXs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(steps.length, (stepIndex) {
          final isCompleted = activeStep > stepIndex;
          final isActive = activeStep == stepIndex;
          final isAllowed = stepIndex <= maxStep;

          return Expanded(
            child: GestureDetector(
              onTap: isAllowed && onStepReached != null
                  ? () => onStepReached!(stepIndex)
                  : null,
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Left connector half
                      Expanded(
                        child: stepIndex == 0
                            ? const SizedBox.shrink()
                            : _buildHalfConnector(
                                context: context,
                                isFilled: activeStep >= stepIndex,
                              ),
                      ),
                      // Step Circle
                      _buildStepCircle(
                        context: context,
                        stepIndex: stepIndex,
                        step: steps[stepIndex],
                        isCompleted: isCompleted,
                        isActive: isActive,
                        circleSize: circleSize,
                      ),
                      // Right connector half
                      Expanded(
                        child: stepIndex == steps.length - 1
                            ? const SizedBox.shrink()
                            : _buildHalfConnector(
                                context: context,
                                isFilled: activeStep > stepIndex,
                              ),
                      ),
                    ],
                  ),
                  context.verticalSpace(6),
                  _buildStepTitle(
                    context: context,
                    step: steps[stepIndex],
                    isActive: isActive,
                    isCompleted: isCompleted,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepCircle({
    required BuildContext context,
    required int stepIndex,
    required MyStep step,
    required bool isCompleted,
    required bool isActive,
    required double circleSize,
  }) {
    final colors = context.colorScheme;

    final Color bgColor;
    final Color fgColor;
    final Color borderColor;

    if (isActive) {
      bgColor = colors.primary;
      fgColor = colors.onPrimary;
      borderColor = colors.primary.withValues(alpha: 0.25);
    } else if (isCompleted) {
      bgColor = colors.primary;
      fgColor = colors.onPrimary;
      borderColor = Colors.transparent;
    } else {
      bgColor = colors.surfaceContainerHighest;
      fgColor = colors.onSurfaceVariant;
      borderColor = colors.outlineVariant;
    }

    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeInOutCubic,
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        borderRadius: context.brM,
        color: bgColor,
        border: Border.all(
          color: borderColor,
          width: isActive ? context.setSize(1.5) : context.setSize(1.0),
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: animationDuration,
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: anim,
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: isCompleted
              ? MyIcon(
                  key: const ValueKey('check_icon'),
                  icon: AppIcons.check,
                  size: context.setSize(16),
                  color: fgColor,
                )
              : MyIcon(
                  key: ValueKey('step_icon_$stepIndex'),
                  icon: step.icon,
                  size: context.setSize(15),
                  color: fgColor,
                ),
        ),
      ),
    );
  }

  Widget _buildHalfConnector({
    required BuildContext context,
    required bool isFilled,
  }) {
    final colors = context.colorScheme;
    final lineHeight = context.setSize(2.0);

    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeInOutCubic,
      height: lineHeight,
      decoration: BoxDecoration(
        color: isFilled
            ? colors.primary
            : colors.outlineVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(lineHeight),
      ),
    );
  }

  Widget _buildStepTitle({
    required BuildContext context,
    required MyStep step,
    required bool isActive,
    required bool isCompleted,
  }) {
    final colors = context.colorScheme;

    final Color textColor = (isActive || isCompleted)
        ? colors.primary
        : colors.onSurfaceVariant;

    final FontWeight fontWeight = isActive
        ? FontWeight.bold
        : (isCompleted ? FontWeight.w600 : FontWeight.normal);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedDefaultTextStyle(
          duration: animationDuration,
          curve: Curves.easeInOutCubic,
          textAlign: TextAlign.center,
          style: (context.textTheme.labelMedium ?? const TextStyle()).copyWith(
            fontWeight: fontWeight,
            color: textColor,
            fontSize: context.setSize(isActive ? 11.5 : 11.0),
          ),
          child: Text(
            step.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        if (step.subtitle != null && step.subtitle!.isNotEmpty) ...[
          context.verticalSpace(2),
          Text(
            step.subtitle!,
            style: context.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: context.setSize(9.5),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
