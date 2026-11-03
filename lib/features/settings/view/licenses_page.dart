import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ContextExtensionss;
import 'package:status_saver/core/constants/app_icons.dart';
import 'package:status_saver/core/utils/extensions/context_extension.dart';
import 'package:status_saver/core/utils/extensions/responsive_values.dart';
import 'package:status_saver/features/settings/controller/licenses_controller.dart';
import 'package:status_saver/shared/widgets/appbars/my_app_bar.dart';
import 'package:status_saver/shared/widgets/input/my_text_field.dart';
import 'package:status_saver/shared/widgets/misc/my_empty_state.dart';
import 'package:status_saver/shared/widgets/misc/my_progress_indicator.dart';
import 'package:status_saver/shared/widgets/tiles/my_list_tile.dart';

/// A production-ready page displaying third-party open-source software licenses.
///
/// Uses [LicensesController] for state management and [CustomScrollView] so the
/// search field scrolls alongside the package list.
class LicensesPage extends StatelessWidget {
  const LicensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<LicensesController>()
        ? Get.find<LicensesController>()
        : Get.put(LicensesController());

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: MyAppBar(title: context.l10n.openSourceLicenses),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: context.insetsAllM.copyWith(bottom: 0),
              child: MyTextField(
                controller: controller.searchController,
                isSearch: true,
                hintText: context.l10n.search,
                prefixIcon: AppIcons.search,
                onChanged: controller.onSearchChanged,
              ),
            ),
          ),
          Obx(() {
            if (controller.isLoading.value) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: MyProgressIndicator()),
              );
            }

            if (controller.errorMessage.value != null) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: MyEmptyState(
                    icon: AppIcons.error,
                    title: context.l10n.failedToLoadLicenses,
                    subtitle: controller.errorMessage.value!,
                    actionText: context.l10n.retry,
                    onAction: controller.retry,
                  ),
                ),
              );
            }

            if (controller.allPackages.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: MyEmptyState(
                    icon: AppIcons.receipt,
                    title: context.l10n.noLicensesFound,
                    subtitle: context.l10n.noLicensesFoundSubtitle,
                  ),
                ),
              );
            }

            final filtered = controller.filteredPackages;
            if (filtered.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: MyEmptyState(
                    icon: AppIcons.searchOff,
                    title: context.l10n.noResultsFound,
                    subtitle: context.l10n.noDataSubtitle,
                    actionText: context.l10n.clear,
                    onAction: controller.clearSearch,
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: context.insetsVerticalM,
              sliver: SliverList.separated(
                itemCount: filtered.length,
                separatorBuilder: (context, index) {
                  return context.verticalSpace(2);
                },
                itemBuilder: (context, index) {
                  final package = filtered[index];
                  return MyListTile(
                    key: ValueKey(package.packageName),
                    title: package.packageName,
                    subtitle: context.l10n.licensesCount(
                      package.licenses.length,
                    ),
                    borderRadius: BorderRadius.zero,
                    onTap: () => controller.openLicenseDetails(package),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

