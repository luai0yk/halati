import 'package:flutter/foundation.dart';

@immutable
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  String toString() => '$runtimeType: $message${code != null ? ' ($code)' : ''}';
}

class SafPermissionDeniedFailure extends Failure {
  const SafPermissionDeniedFailure([super.message = 'SAF permission was denied by user', super.code]);
}

class SafFolderInvalidFailure extends Failure {
  const SafFolderInvalidFailure([super.message = 'The selected folder is not the WhatsApp .Statuses folder', super.code]);
}

class SafAccessRevokedFailure extends Failure {
  const SafAccessRevokedFailure([super.message = 'Folder access permission was revoked or expired', super.code]);
}

class MediaReadFailure extends Failure {
  const MediaReadFailure([super.message = 'Failed to read media from storage', super.code]);
}

class ThumbnailGenerationFailure extends Failure {
  const ThumbnailGenerationFailure([super.message = 'Failed to generate media thumbnail', super.code]);
}

class MediaStoreSaveFailure extends Failure {
  const MediaStoreSaveFailure([super.message = 'Failed to save media to gallery', super.code]);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Database operation failed', super.code]);
}
