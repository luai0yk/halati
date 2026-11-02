class SafChannel {
  SafChannel._();

  static const String channelName = 'com.luai0yk.status_saver/saf';

  // Methods
  static const String checkDirectoryAccess = 'checkDirectoryAccess';
  static const String requestDirectorySelection = 'requestDirectorySelection';
  static const String releaseDirectoryAccess = 'releaseDirectoryAccess';
  static const String discoverStatuses = 'discoverStatuses';
  static const String getThumbnail = 'getThumbnail';
  static const String getMediaMetadata = 'getMediaMetadata';
  static const String saveToMediaStore = 'saveToMediaStore';
  static const String getFullMediaFile = 'getFullMediaFile';
  static const String deleteFromMediaStore = 'deleteFromMediaStore';
}
