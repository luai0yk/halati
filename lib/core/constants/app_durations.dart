/// Animation durations used throughout the application.
abstract final class AppDurations {
  AppDurations._();

  /// 100ms - Very fast interactions (hovers, tiny icon toggles).
  static const Duration veryFast = Duration(milliseconds: 100);

  /// 200ms - Fast interactions (buttons, ripples, small state changes).
  static const Duration fast = Duration(milliseconds: 200);

  /// 300ms - Default Material animation duration.
  static const Duration medium = Duration(milliseconds: 300);

  /// 400ms - Slightly slower transitions.
  static const Duration slow = Duration(milliseconds: 400);

  /// 500ms - Long transitions (page sections, dialogs, larger UI changes).
  static const Duration verySlow = Duration(milliseconds: 500);
}
