import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teen_talk_app/src/features/tutorial/data/services/tutorial_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('TutorialService', () {
    test('should return false when tutorial not completed', () async {
      final service = TutorialService();
      final isCompleted = await service.isTutorialCompleted();
      expect(isCompleted, isFalse);
    });

    test('should return true after marking tutorial completed', () async {
      final service = TutorialService();
      await service.markTutorialCompleted();
      final isCompleted = await service.isTutorialCompleted();
      expect(isCompleted, isTrue);
    });

    test('should return false when tutorial not skipped', () async {
      final service = TutorialService();
      final isSkipped = await service.isTutorialSkipped();
      expect(isSkipped, isFalse);
    });

    test('should return true after marking tutorial skipped', () async {
      final service = TutorialService();
      await service.markTutorialSkipped();
      final isSkipped = await service.isTutorialSkipped();
      expect(isSkipped, isTrue);
    });

    test('shouldShowTutorial returns true when not completed and not skipped', () async {
      final service = TutorialService();
      final shouldShow = await service.shouldShowTutorial();
      expect(shouldShow, isTrue);
    });

    test('shouldShowTutorial returns false when completed', () async {
      final service = TutorialService();
      await service.markTutorialCompleted();
      final shouldShow = await service.shouldShowTutorial();
      expect(shouldShow, isFalse);
    });

    test('shouldShowTutorial returns false when skipped', () async {
      final service = TutorialService();
      await service.markTutorialSkipped();
      final shouldShow = await service.shouldShowTutorial();
      expect(shouldShow, isFalse);
    });

    test('resetTutorial clears all tutorial flags', () async {
      final service = TutorialService();
      await service.markTutorialCompleted();
      await service.markTutorialSkipped();
      
      await service.resetTutorial();
      
      final isCompleted = await service.isTutorialCompleted();
      final isSkipped = await service.isTutorialSkipped();
      final shouldShow = await service.shouldShowTutorial();
      
      expect(isCompleted, isFalse);
      expect(isSkipped, isFalse);
      expect(shouldShow, isTrue);
    });
  });
}
