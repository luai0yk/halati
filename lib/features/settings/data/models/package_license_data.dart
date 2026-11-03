import 'package:flutter/foundation.dart';

/// Represents a package and its associated license entries.
class PackageLicenseData {
  final String packageName;
  final List<LicenseEntry> licenses;

  const PackageLicenseData({required this.packageName, required this.licenses});
}

