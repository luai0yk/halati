import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:status_saver/core/utils/extensions/context_extension.dart';
import 'package:status_saver/core/utils/extensions/responsive_size.dart';
import 'package:status_saver/core/utils/extensions/responsive_values.dart';
import 'package:status_saver/features/settings/data/models/package_license_data.dart';
import 'package:status_saver/shared/widgets/sheets/my_bottom_sheet.dart';

/// Bottom sheet displaying the full license details for a specific package.
class LicenseDetailsSheet extends StatelessWidget {
  final PackageLicenseData package;

  const LicenseDetailsSheet({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return MyBottomSheet(
      title: package.packageName,
      openWithMaxHeight: true,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: context.spaceS),
        child: SelectionArea(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: _buildLicensesContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildLicensesContent(BuildContext context) {
    final licenses = package.licenses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < licenses.length; i++) ...[
          if (licenses.length > 1) ...[
            if (i > 0)
              Divider(
                height: context.setSize(24),
                thickness: 1,
                color: context.colorScheme.outlineVariant.withValues(
                  alpha: 0.3,
                ),
              ),
            Padding(
              padding: EdgeInsets.only(bottom: context.spaceS),
              child: Text(
                'License ${i + 1}',
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          _buildLicenseEntry(context, licenses[i]),
        ],
      ],
    );
  }

  Widget _buildLicenseEntry(BuildContext context, LicenseEntry entry) {
    final paragraphs = entry.paragraphs.toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final paragraph in paragraphs) _buildParagraph(context, paragraph),
      ],
    );
  }

  Widget _buildParagraph(BuildContext context, LicenseParagraph paragraph) {
    if (paragraph.indent == LicenseParagraph.centeredIndent) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: context.setSize(8)),
        child: Text(
          paragraph.text,
          textAlign: TextAlign.center,
          style: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colorScheme.onSurface,
            height: 1.4,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: context.setSize(paragraph.indent * 16.0),
        top: context.setSize(3),
        bottom: context.setSize(3),
      ),
      child: Text(
        paragraph.text,
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
          height: 1.4,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

