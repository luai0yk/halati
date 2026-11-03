import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ContextExtensionss;
import 'package:status_saver/core/utils/helpers/ui/bottom_sheet_helper.dart';
import 'package:status_saver/features/settings/data/models/package_license_data.dart';
import 'package:status_saver/features/settings/data/services/licenses_service.dart';
import 'package:status_saver/features/settings/view/widgets/license_details_sheet.dart';

/// GetX controller managing license loading, filtering, and detail navigation.
class LicensesController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();
  final RxList<PackageLicenseData> allPackages = <PackageLicenseData>[].obs;
  final RxList<PackageLicenseData> filteredPackages =
      <PackageLicenseData>[].obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadLicenses();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// Loads license data from the cached service.
  Future<void> loadLicenses({bool forceRefresh = false}) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final packages = await LicensesService.instance.loadLicenses(
        forceRefresh: forceRefresh,
      );

      allPackages.assignAll(packages);
      applySearchFilter(searchQuery.value);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Handles real-time search query changes.
  void onSearchChanged(String query) {
    searchQuery.value = query;
    applySearchFilter(query);
  }

  /// Applies case-insensitive filtering to package names.
  void applySearchFilter(String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      filteredPackages.assignAll(allPackages);
    } else {
      filteredPackages.assignAll(
        allPackages.where((p) => p.packageName.toLowerCase().contains(trimmed)),
      );
    }
  }

  /// Clears the search field and resets the filtered package list.
  void clearSearch() {
    searchController.clear();
    onSearchChanged('');
  }

  /// Retries loading license data with forced refresh.
  void retry() {
    loadLicenses(forceRefresh: true);
  }

  /// Opens the license details in a bottom sheet via [BottomSheetHelper].
  void openLicenseDetails(PackageLicenseData package) {
    BottomSheetHelper.show(child: LicenseDetailsSheet(package: package));
  }
}

