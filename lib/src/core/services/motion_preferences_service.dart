import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MotionPreferences {
  const MotionPreferences({
    required this.prefersReducedMotion,
    required this.prefersHighContrast,
    required this.allowHeavyAnimations,
  });

  final bool prefersReducedMotion;
  final bool prefersHighContrast;
  final bool allowHeavyAnimations;

  bool get shouldDisableAnimations => prefersReducedMotion || !allowHeavyAnimations;

  MotionPreferences copyWith({
    bool? prefersReducedMotion,
    bool? prefersHighContrast,
    bool? allowHeavyAnimations,
  }) {
    return MotionPreferences(
      prefersReducedMotion: prefersReducedMotion ?? this.prefersReducedMotion,
      prefersHighContrast: prefersHighContrast ?? this.prefersHighContrast,
      allowHeavyAnimations: allowHeavyAnimations ?? this.allowHeavyAnimations,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MotionPreferences &&
        other.prefersReducedMotion == prefersReducedMotion &&
        other.prefersHighContrast == prefersHighContrast &&
        other.allowHeavyAnimations == allowHeavyAnimations;
  }

  @override
  int get hashCode =>
      prefersReducedMotion.hashCode ^
      prefersHighContrast.hashCode ^
      allowHeavyAnimations.hashCode;
}

class MotionPreferencesService extends ChangeNotifier {
  MotionPreferencesService(this._prefs) {
    _init();
  }

  final SharedPreferences _prefs;
  
  static const _keyReducedMotion = 'motion_preferences_reduced_motion';
  static const _keyHighContrast = 'motion_preferences_high_contrast';
  static const _keyHeavyAnimations = 'motion_preferences_heavy_animations';

  bool _prefersReducedMotion = false;
  bool _prefersHighContrast = false;
  bool _allowHeavyAnimations = false;
  bool _platformReducedMotion = false;

  MotionPreferences get preferences => MotionPreferences(
        prefersReducedMotion: _prefersReducedMotion || _platformReducedMotion,
        prefersHighContrast: _prefersHighContrast,
        allowHeavyAnimations: _allowHeavyAnimations,
      );

  Future<void> _init() async {
    _prefersReducedMotion = _prefs.getBool(_keyReducedMotion) ?? false;
    _prefersHighContrast = _prefs.getBool(_keyHighContrast) ?? false;
    _allowHeavyAnimations = _prefs.getBool(_keyHeavyAnimations) ?? false;

    await _checkPlatformAccessibilitySettings();
    notifyListeners();
  }

  Future<void> _checkPlatformAccessibilitySettings() async {
    try {
      const platform = MethodChannel('app.spotted/accessibility');
      final result = await platform.invokeMethod<bool>('getReducedMotion');
      _platformReducedMotion = result ?? false;
    } catch (e) {
      debugPrint('Failed to get platform reduced motion setting: $e');
      _platformReducedMotion = false;
    }
  }

  Future<void> setPrefersReducedMotion(bool value) async {
    _prefersReducedMotion = value;
    await _prefs.setBool(_keyReducedMotion, value);
    notifyListeners();
  }

  Future<void> setPrefersHighContrast(bool value) async {
    _prefersHighContrast = value;
    await _prefs.setBool(_keyHighContrast, value);
    notifyListeners();
  }

  Future<void> setAllowHeavyAnimations(bool value) async {
    _allowHeavyAnimations = value;
    await _prefs.setBool(_keyHeavyAnimations, value);
    notifyListeners();
  }

  Future<void> syncWithUserProfile({
    bool? prefersReducedMotion,
    bool? prefersHighContrast,
    bool? allowHeavyAnimations,
  }) async {
    if (prefersReducedMotion != null) {
      _prefersReducedMotion = prefersReducedMotion;
      await _prefs.setBool(_keyReducedMotion, prefersReducedMotion);
    }
    if (prefersHighContrast != null) {
      _prefersHighContrast = prefersHighContrast;
      await _prefs.setBool(_keyHighContrast, prefersHighContrast);
    }
    if (allowHeavyAnimations != null) {
      _allowHeavyAnimations = allowHeavyAnimations;
      await _prefs.setBool(_keyHeavyAnimations, allowHeavyAnimations);
    }
    notifyListeners();
  }
}
