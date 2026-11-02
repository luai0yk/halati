import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CashService extends GetxService {
  late final SharedPreferences _prefs;

  Future<CashService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  /// Check if key exists
  bool contains(String key) {
    return _prefs.containsKey(key);
  }

  /// Reload values from native storage
  Future<void> reload() async {
    await _prefs.reload();
  }

  /// Remove value
  Future<bool> remove(String key) {
    return _prefs.remove(key);
  }

  /// Clear all values
  Future<bool> clear() {
    return _prefs.clear();
  }

  /// Set string value
  Future<bool> setString(String key, String value) {
    return _prefs.setString(key, value);
  }

  /// Get string value
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// Set bool value
  Future<bool> setBool(String key, bool value) {
    return _prefs.setBool(key, value);
  }

  /// Get bool value
  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  /// Set int value
  Future<bool> setInt(String key, int value) {
    return _prefs.setInt(key, value);
  }

  /// Get int value
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  /// Set double value
  Future<bool> setDouble(String key, double value) {
    return _prefs.setDouble(key, value);
  }

  /// Get double value
  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  /// Set string list value
  Future<bool> setStringList(String key, List<String> value) {
    return _prefs.setStringList(key, value);
  }

  /// Get string list value
  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  /// Save json model
  Future<bool> setModel(String key, Map<String, dynamic> json) {
    final jsonString = jsonEncode(json);

    return _prefs.setString(key, jsonString);
  }

  /// Get json model
  T? getModel<T>(String key, T Function(Map<String, dynamic> json) fromJson) {
    final jsonString = _prefs.getString(key);

    if (jsonString == null) {
      return null;
    }

    try {
      final decoded = jsonDecode(jsonString);

      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return fromJson(decoded);
    } catch (_) {
      return null;
    }
  }
}
