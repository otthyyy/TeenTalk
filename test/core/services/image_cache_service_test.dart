import 'package:flutter_test/flutter_test.dart';
import 'package:teen_talk_app/src/core/services/image_cache_service.dart';

void main() {
  group('ImageCacheService', () {
    late ImageCacheService service;

    setUp(() {
      service = ImageCacheService();
    });

    test('should be a singleton', () {
      final instance1 = ImageCacheService();
      final instance2 = ImageCacheService();
      expect(instance1, same(instance2));
    });

    test('precacheImage handles empty URLs gracefully', () async {
      await expectLater(
        service.precacheImage(''),
        completes,
      );
    });

    test('precacheImages handles empty list gracefully', () async {
      await expectLater(
        service.precacheImages([]),
        completes,
      );
    });

    test('getCacheInfo returns valid structure', () async {
      final info = await service.getCacheInfo();
      expect(info, isA<Map<String, dynamic>>());
      expect(info.containsKey('fileCount'), true);
      expect(info.containsKey('totalSizeBytes'), true);
      expect(info.containsKey('totalSizeMB'), true);
      expect(info['fileCount'], isA<int>());
      expect(info['totalSizeBytes'], isA<int>());
      expect(info['totalSizeMB'], isA<String>());
    });
  });
}
