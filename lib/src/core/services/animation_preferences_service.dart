import 'package:shared_preferences/shared_preferences.dart';

class AnimationPreferencesService {
  static const String _hasSeenIntroKey = 'has_seen_intro';
  static const String _motionEnabledKey = 'motion_enabled';

  Future<bool> hasSeenIntro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenIntroKey) ?? false;
  }

  Future<void> markIntroSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenIntroKey, true);
  }

  Future<void> resetIntro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasSeenIntroKey);
  }

  Future<bool> isMotionEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_motionEnabledKey) ?? true;
  }

  Future<void> setMotionEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_motionEnabledKey, enabled);
  }

  bool shouldSkipSplashAnimation() {
    const skipAnimation = bool.fromEnvironment(
      'SKIP_SPLASH_ANIMATION',
      defaultValue: false,
    );
    return skipAnimation;
  }
}
