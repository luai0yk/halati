import 'package:flutter_test/flutter_test.dart';
import 'package:halati/features/home/data/models/status_media_model.dart';
import 'package:halati/features/home/domain/entities/status_media.dart';

void main() {
  group('StatusMediaModel Classification and Serialization', () {
    test('correctly parses image status', () {
      final map = {
        'id': 'image_1',
        'documentUri':
            'content://com.android.externalstorage.documents/document/image_1',
        'fileName': 'status_photo.jpg',
        'mediaType': 'image',
        'mimeType': 'image/jpeg',
        'size': 102400,
        'lastModified': 1700000000,
      };

      final model = StatusMediaModel.fromMap(map);

      expect(model.id, 'image_1');
      expect(model.mediaType, MediaType.image);
      expect(model.fileName, 'status_photo.jpg');
      expect(model.size, 102400);
      expect(model.lastModified, 1700000000);
    });

    test('correctly parses video status', () {
      final map = {
        'id': 'video_1',
        'documentUri':
            'content://com.android.externalstorage.documents/document/video_1',
        'fileName': 'status_clip.mp4',
        'mediaType': 'video',
        'mimeType': 'video/mp4',
        'size': 5120000,
        'lastModified': 1700000100,
        'durationMs': 15000,
      };

      final model = StatusMediaModel.fromMap(map);

      expect(model.id, 'video_1');
      expect(model.mediaType, MediaType.video);
      expect(model.durationMs, 15000);
    });

    test('correctly parses audio / voice status', () {
      final map = {
        'id': 'audio_1',
        'documentUri':
            'content://com.android.externalstorage.documents/document/audio_1',
        'fileName': 'voice_note.opus',
        'mediaType': 'audio',
        'mimeType': 'audio/ogg; codecs=opus',
        'size': 32000,
        'lastModified': 1700000200,
        'durationMs': 28000,
      };

      final model = StatusMediaModel.fromMap(map);

      expect(model.id, 'audio_1');
      expect(model.mediaType, MediaType.audio);
      expect(model.durationMs, 28000);
    });

    test('toMap converts models back to serializable map', () {
      const model = StatusMediaModel(
        id: '123',
        documentUri: 'content://uri',
        fileName: 'test.jpg',
        mediaType: MediaType.image,
        mimeType: 'image/jpeg',
        size: 500,
        lastModified: 1000,
      );

      final map = model.toMap();
      expect(map['id'], '123');
      expect(map['mediaType'], 'image');
      expect(map['fileName'], 'test.jpg');
    });
  });
}
