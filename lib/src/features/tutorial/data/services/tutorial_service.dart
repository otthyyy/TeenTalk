import 'package:shared_preferences/shared_preferences.dart';

class TutorialService {
  static const String _tutorialCompletedKey = 'app_tutorial_completed';
  static const String _tutorialSkippedKey = 'app_tutorial_skipped';

  Future<bool> isTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tutorialCompletedKey) ?? false;
  }

  Future<void> markTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialCompletedKey, true);
  }

  Future<bool> isTutorialSkipped() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tutorialSkippedKey) ?? false;
  }

  Future<void> markTutorialSkipped() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialSkippedKey, true);
  }

  Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tutorialCompletedKey);
    await prefs.remove(_tutorialSkippedKey);
  }

  Future<bool> shouldShowTutorial() async {
    final completed = await isTutorialCompleted();
    final skipped = await isTutorialSkipped();
    return !completed && !skipped;
  }
}
