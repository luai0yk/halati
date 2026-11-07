import 'package:flutter/foundation.dart';
import 'package:halati/features/settings/data/models/package_license_data.dart';

/// Service responsible for loading and aggregating license data from [LicenseRegistry].
///
/// Implements caching to prevent redundant stream processing across page visits.
class LicensesService {
  LicensesService._();

  static final LicensesService instance = LicensesService._();

  List<PackageLicenseData>? _cachedLicenses;

  /// Loads all license entries from [LicenseRegistry], groups them by package,
  /// sorts packages alphabetically (case-insensitive), and caches the result.
  Future<List<PackageLicenseData>> loadLicenses({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedLicenses != null) {
      return _cachedLicenses!;
    }

    final Map<String, List<LicenseEntry>> packageMap = {};

    await for (final LicenseEntry entry in LicenseRegistry.licenses) {
      for (final String package in entry.packages) {
        packageMap.putIfAbsent(package, () => []).add(entry);
      }
    }

    final sortedKeys = packageMap.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    _cachedLicenses = sortedKeys
        .map(
          (pkg) => PackageLicenseData(
            packageName: pkg,
            licenses: List.unmodifiable(packageMap[pkg]!),
          ),
        )
        .toList(growable: false);

    return _cachedLicenses!;
  }

  /// Clears in-memory cache.
  @visibleForTesting
  void clearCache() {
    _cachedLicenses = null;
  }
}
